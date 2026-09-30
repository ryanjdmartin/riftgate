# To-do

One line per task: the specific thing to do, and what unblocks it when something does.
Grouped by who moves it. Tick a line when it lands, in the same commit as the work; the
next session prunes ticked lines. This file says only what is next. Why, and the
direction behind it, live in the bible (section 12 is the roadmap); how things stand
today lives in `docs/status.md`. "Discuss first" means a proposal in chat before code.

## Ryan

- [ ] Decide the engagement rule (29 September: the range chains across the map and hides who joins; the bible's section 5 carries the proposal, a pack's capture zone of radius two with the zones always drawn and the tethers retired, and Ryan's three variants weighed); then build it
- [ ] Judge on the phone after a re-export: the machines' outline at 2.6 (`MechView3D.OUTLINE`; 1.0 was the thin), the violet intent marks against the blue HUD, the orange pulse of the gate's hazard glyphs, the sound set, the grid at `GRID_GAIN_PHONE`
- [x] Judged 29 September on the phone: 60 fps with the fine map and the per-hex props, the text clean, the board and log button, the selection marks, the routes, the props hiding, the seam band, the far blur
- [ ] Codex and flavour for the seven new machines, the Baboon's flavour, and the 41 components whose codex is empty
- [x] Decide the Dingo's name (29 September: kept, the coincidence tier; every flagged name is now decided and every note says why it stays)
- [ ] The Badger's joints in Blender (`forge.py export badger`)
- [x] The missing model pins (29 September, night: the Clydesdale's nine and the Sparrowhawk's four, and the Badger's hp_4 as a slab where a second cannon stood; the codex page flags nothing now)
- [ ] Judge the pins pass and the seven classes on the Model Viewer's Classes section: the Badger's right-pauldron slab, the Clydesdale's howitzer, barrage rack and flak skirt, the Sparrowhawk's spine dish; each class's size per machine (a pin's `scale` in `models_low.py`); and whether a stock part should be the class shape rather than the hand-modelled part
- [x] Picks from the phone sketches page: the bass voice (3 or 5), the clip-free guitar, the third shadows (28 September: voice 12, the guitar, the third cut, a quarter of the level gap; all in the forge)
- [x] Judge The Far Bank's tempo in the game (29 September: 88 stays; the temporary ids are gone)
- [ ] Hold The Line at 104 in the game: the seven's twelve bars with the held guitar a whole bar each on E, D, D flat, C (twice), the keys' lead adding thirds and roots under its tune as the bridge builds, the drone up, the second lift's bass down, the kit up, the wrap into bar nine; notes by section letter
- [x] Judge round six (29 September: the middle kick ships; the powers were louder, not harder)
- [x] Judge round eight (30 September: hard two ships, at its own pitch)
- [x] Judge round nine (30 September: piano and second chug out, chimes in sets two and three at 0.3, drone throughout, the keys' lead on the riff from mid set two)
- [x] Write the bridge's melody on the Melody Desk (30 September: sent, applied as the keys section's lead and two harmony voices, marked applied)
- [x] Judge the drums' last dial-in from the sketches page's "Now" set: `mix_ship` (the track as it ships), `drums_kick` (the kick's size, three steps down) and `drums_tom` (the toms, three steps tighter); say which step, or further
- [ ] Read `docs/balance.md` against your own play; then either the numbers move or the bot's next rung is built
- [ ] Discuss first, then decide: ally wrecks (block a hex? a round or the battle?)
- [ ] Discuss first, then decide: what terrain does in a skirmish (things the machines feel, never a bonus to the foes)
- [ ] Discuss first, then decide: base defences (gate guns, then turrets; `Battlefield.defenses()` is empty)
- [ ] Discuss first, then decide: the reinforcement phase, and whether skirmish composition follows placement
- [ ] Discuss first, then decide: when and how the multi-hex boss comes back (`Unit.TRIANGLE` waits)
- [ ] Discuss first, then decide: Rift Pressure feeding packs into the boss fight, so bum-rushing the boss is a race between temporary power gained and the boss's reinforcements (Ryan, 29 September: valid, fits the complexity wanted, tight to balance; hinges on how strong the in-battle temporary upgrades are, which do not exist yet)
- [ ] Discuss first, then decide: the final battle's source rift has a boss of its own (Ryan's lean, 29 September: probably yes, as the campaign's climax; The Far Bank may be that boss's track, being more doom-and-gloom than a fight, which would leave The Chorus wanting a theme from a seed)
- [ ] Discuss first, then decide: the economy and the blueprint tiers (nothing that prices anything can be designed before this)
- [ ] Discuss first, then decide: does a pack keep its foes' hull between fights (a withdrawal leaves them hurt today only in the count), and how the map shows it (the strength segments could show it)
- [ ] The ideas list: burning terrain, statuses carried between fights, hunter packs, hull repair
- [ ] Movespeed in tens like every other number, or in hexes as now
- [ ] Enemy targeting among machines in a skirmish (lowest shield, highest heat, last attacker, random) and how it is telegraphed
- [ ] The game's name
- [ ] Name and brief the second Aphelion machine: a hovercraft that runs hot, with heat as the suite's power (a stack per 20 heat held on every status it applies); a venomous sea creature's name; built after buffs exist

## Engine

The planned pieces the 28 September content leans on, one line each, in whichever order Ryan wants to play first (every one is `"status": "planned"` in content and flips to implemented in the same commit):

- [ ] `volatile`: a spend bites its owner for 10 hull past shield and armour (the Corrupted bite's path); Gravity Knuckles
- [ ] `devour` and the Overcharged status: a kill adds a stack, +10% damage a stack, decays a round at a time; needs an on-kill hook; Soulcutter Talons
- [ ] Shocked (the next blow taken deals double; a Shocked foe striking bare hull again takes 10) and retaliate as the status that applies it; the Armadillo's Faraday Hull
- [ ] `taunt` as a status a shield face applies (front-rank foes target the machine); Proximity Klaxon, Faraday Shutters, and the shutters' Live Shell that shocks through a blocked blow
- [ ] `overwhelm` (damage past a kill spills into the rank behind) and its grant on every attack; Juggernaut Drive
- [ ] The stealth join rule: in a fight only beside an ally or when it stopped a pack in its path; needs the blocked list to name the blocker; the Dingo
- [ ] The vent-on-fire face (`vents_all`, `power_per_heat`); the Afterburner Cannon
- [ ] Battery Director: rerolling only the Clydesdale's die is free once a round, on top of the team's three
- [ ] Thermal Recoupler: shield regained per 10 heat at the start of the Goshawk's turn, the first in-fight regen
- [ ] Static-screen Projector: on withdraw the Prairie Dog is out before the enemy strikes, each ally rolls an even chance, a blow at a covered machine is lost
- [ ] Crucible Capacitor: melee damage per Overheating stack, a stack per blow that reaches hull from a foe or its own weapons, never from overheat burn
- [ ] Tactical Databank: kinetic weapons roll their maximum with an ally in the fight; needs an ally-present condition
- [ ] Glacis: the Breaching Plow's armour against front-rank blows only, once the engine knows which rank struck (flat +5 today)
- [ ] The planned statuses still without an engine: Phased, Beacon, Energy Armour
- [ ] The planned player keywords: Corrode, Scramble, Confuse
- [ ] The planned triggers: on shield gain, on heat gain, on round start, on skirmish start, on hull damage, out of combat
- [ ] Foe roles, and the ten planned foe actions in `content/foes.json` (buff, defend and debuff kinds running; every foe status they grant fires `on_foe_status`)
- [x] Buff equipment (29 September): the `buff` kind grants a machine status for so many stacks and rounds; Overcharged, Braced and Primed as the first three; the Overcharge Coil as a draft component fitted to nothing; the heat passive above can now be built on it
- [x] Granted passives coloured on the codex (29 September, night: `passive_rows` by source; the chassis's own in the accent, a component's in the overlay colour, a reward in ink)
- [ ] Save and resume mid-battle at any phase (nothing is serialised yet)
- [ ] Onboarding: the gesture tutorial and the cheat sheet; the reroll rule and the zone of control first
- [x] The bot values a status for the stun it may cause (29 September: `_loop_chance` in `policy.gd`, at the loop's odds and the foe's resistance) and weighs a buff by what its status does to the machine it lands on
- [ ] Rerun `tools/balance.gd` once the new machines have real kits, and after each engine piece above; read bands, not numbers

## Map and screens

- [x] The black gap between the map's frame and the log was the readout's reserved strip, empty until a hold; it now carries the orders board (`OrdersBoard`, 28 September). Ryan judges it on the phone
- [ ] The wreck's death animation on the map, once wrecks are decided
- [ ] Joint idle for grounded machines, once joints exist
- [ ] Corruption in a pack's wake, and the bleed growing with Rift Pressure (`bleed.gd` has the knob in mind), once decided
- [x] FINE MAP judged on the phone (29 September): 60 fps locked, now the default; MSAA measured leaking and is unreachable on a phone
- [ ] If the phone drops frames: one mesh per material per machine, until joints
- [x] `tools/screenshot.gd`'s engage pose prints renderer leak warnings at exit (29 September, night: the skirmish screen waiting on the handover tween was an orphan at exit; the battle screen frees it on predelete)

## Art

- [x] lowforge briefs and models for the seven new machines (first passes, 29 September; every hardpoint has its pin, every fixed component is modelled in); Ryan iterates by render
- [ ] Ryan: notes on the seven second-pass models (renders: the Model Viewer, https://claude.ai/artifact/HzF8K98MxgJP7kroxAuDMv)
- [x] Silhouette classes for components (29 September, night: seven classes in `models_low.SHAPES`, a blade added for the melee arms; `forge.py shapes` builds every maker's metal into `art/models/shapes`; `shape` validated on every component; every chassis pin parents its stock part; `MechView3D.mount_plan` and `plan_for` from the skirmish, the codex and the portrait; `RIFTGATE_FIT` on the hero shot)
- [ ] Ryan: judge the Baboon's rear silhouette in the harness (the fists hang at knee height now, not on the ground); if it still reads as carrying two boxes, pick heavier hands carrying hardware or a standard forward pose with the fist tile turned 90 degrees
- [ ] Enemy art through foeforge for the foes still on sketch grids
- [ ] The hangar as a model
- [ ] Per-mech repaint (`Unit.paint` exists; nothing sets it)
- [ ] A licensed icon set (game-icons.net, CC BY) rendered to textures, replacing the line-drawn glyphs in one pass

## Pages (standing, after every content change)

- [x] Joining the accounts (29 September): done. Nameplate, codex and phone sketches are shared to the work email as Editor and open there; A merged B's 42 component rows into its nameplate (an invited editor from another organisation cannot use a page's database from Claude Code, so B exported and A imported); the bible's and viewer's invites do not arrive, Ryan retries later, B keeps its own bible copy meanwhile. B's nameplate copy is deleted (29 September, night); B keeps only its bible copy and the content editor
- The content editor, when it exists again: republish it with its `files` map after every content change, or its baselines go stale (source `tools/content_editor.html`)
- [ ] When Ryan wants to edit content from his phone again: publish the content editor from account A (`tools/content_editor.html` with its `files` map carrying `content/*.json`) and share it to the work email as Editor; the old B page is gone, its edits database was empty
- Rebake the nameplate page's baked-in current names (`CURRENT` in its script) when a chassis or component is added or renamed
- Republish the bible from the committed file (each account to its own URL, listed in status)
- Regenerate the hangar codex (`python3 tools/build_codex.py . codex.html`) after a content or model change and republish it, each account to its own copy; it reads the built `.glb` files, so build and import first

## Audio

- [x] Rebuild the rift tracks on the one master (tilt 1.5 plus presence)
- [x] Land Ryan's phone-sketch picks in the forge (28 September: the driven bass, the backing guitar, the kick, the toms, the crash, the sub's shadow, the rift levels)
- [ ] A speakers or headphones setting (default speaker on a phone; Godot cannot tell what is plugged in): shipped levels for headphones, an offset per track and an EQ on the music bus for the speaker profile; discuss the offsets first
- [ ] The Risen and Infernal Horde boss themes from their seeds; melodies proposed in chat first
- ~~The Far Bank's wrap at bar nine lands without the room's tail~~ (Ryan, 29 September: the loop is fine)
- ~~A light tight kick under The Far Bank's bass drum, as a sketch~~ (Ryan, 29 September: not missing any bass on the phone)
- ~~The real recordings and the real track: who makes them~~ (Ryan, 29 September: no decision needed, the forge on this computer is the instrument)

## Pinned, not now

- Low-hull berserker or last-stand ability
- Command die faces with a second, battlefield meaning
- Endless mode after the bounded campaign
- Hardwired hardpoints with a paid unlock (waits on the economy)

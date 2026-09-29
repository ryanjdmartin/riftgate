# To-do

One line per task: the specific thing to do, and what unblocks it when something does.
Grouped by who moves it. Tick a line when it lands, in the same commit as the work; the
next session prunes ticked lines. This file says only what is next. Why, and the
direction behind it, live in the bible (section 12 is the roadmap); how things stand
today lives in `docs/status.md`. "Discuss first" means a proposal in chat before code.

## Ryan

- [ ] Play-test the engagement range (`Battlefield.ENGAGE_RANGE` = 2) and the tethers; say whether formations are still wanted
- [ ] Judge on the phone after a re-export: frame rate (the per-hex props added draw calls), the sound set, the machines' edges without MSAA, the text, the grid at `GRID_GAIN_PHONE`, the seam band (less green than before), the far blur, the board and the log button, the selection marks, the routes, props hiding under a machine
- [ ] Codex and flavour for the seven new machines, the Baboon's flavour, and the 41 components whose codex is empty
- [ ] Decide the Dingo's name (`design.name_clash`: a Heavy Gear Northern gear); the Sparrowhawk, Goshawk, Baboon and the badger id are kept
- [ ] The Badger's joints and pins in Blender (`forge.py export badger`); the missing model pins: the Clydesdale has 6 for 9 hardpoints, the Sparrowhawk 2 for 4 (wing pods only); the codex page flags both until then
- [x] Picks from the phone sketches page: the bass voice (3 or 5), the clip-free guitar, the third shadows (28 September: voice 12, the guitar, the third cut, a quarter of the level gap; all in the forge)
- [x] Judge The Far Bank's tempo in the game (29 September: 88 stays; the temporary ids are gone)
- [ ] Hold The Line: hear the 29 September arrangement in the game (the drone up, the second lift's bass down, the seven's held guitar louder on a descending C B A G, the keys' chords from nothing), the loop's wrap into bar five, and the 104 sketch on the page; notes by section letter
- [ ] Judge round six on the sketches page: the track with the middle kick and with the old kick (say which "original" meant), and the toms hit harder at two powers, bare and in the track
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

The planned pieces the 28 September content leans on, one line each, in whichever order Ryan wants to play first (every one is `"status": "planned"` in content and flips to implemented in the same commit). **Claimed 29 September, night, by the cloud session on branch `ccr-23c2f18f-qlilnd` (Ryan: "work through 1-4"): the engine list below, save and resume, the triggers and foe actions, and the hangar codex republish, in that order; volatile, devour, Shocked, taunt, overwhelm first. Another session should take something else, or say so in this file.**

- [x] `volatile`: a spend bites its owner for 10 hull past shield and armour (the Corrupted bite's path); Gravity Knuckles (29 September, night: on any kind of component; the bot pays for it)
- [x] `devour` and the Overcharged status: a kill adds a stack, +10% damage a stack, decays a round at a time; needs an on-kill hook; Soulcutter Talons (29 September, night: a stack per foe killed, buff and devour stacks add up)
- [ ] Shocked (the next blow taken deals double; a Shocked foe striking bare hull again takes 10) and retaliate as the status that applies it; the Armadillo's Faraday Hull **[claimed 29 September, night: the cloud session on branch `ccr-23c2f18f-qlilnd`; skip unless it says it stopped]**
- [ ] `taunt` as a status a shield face applies (front-rank foes target the machine); Proximity Klaxon, Faraday Shutters, and the shutters' Live Shell that shocks through a blocked blow **[claimed 29 September, night: the cloud session on branch `ccr-23c2f18f-qlilnd`; skip unless it says it stopped]**
- [ ] `overwhelm` (damage past a kill spills into the rank behind) and its grant on every attack; Juggernaut Drive **[claimed 29 September, night: the cloud session on branch `ccr-23c2f18f-qlilnd`; skip unless it says it stopped]**
- [ ] The stealth join rule: in a fight only beside an ally or when it stopped a pack in its path; needs the blocked list to name the blocker; the Dingo **[claimed 29 September, night: the cloud session on branch `ccr-23c2f18f-qlilnd`; skip unless it says it stopped]**
- [ ] The vent-on-fire face (`vents_all`, `power_per_heat`); the Afterburner Cannon **[claimed 29 September, night: the cloud session on branch `ccr-23c2f18f-qlilnd`; skip unless it says it stopped]**
- [ ] Battery Director: rerolling only the Clydesdale's die is free once a round, on top of the team's three **[claimed 29 September, night: the cloud session on branch `ccr-23c2f18f-qlilnd`; skip unless it says it stopped]**
- [ ] Thermal Recoupler: shield regained per 10 heat at the start of the Goshawk's turn, the first in-fight regen **[claimed 29 September, night: the cloud session on branch `ccr-23c2f18f-qlilnd`; skip unless it says it stopped]**
- [ ] Static-screen Projector: on withdraw the Prairie Dog is out before the enemy strikes, each ally rolls an even chance, a blow at a covered machine is lost **[claimed 29 September, night: the cloud session on branch `ccr-23c2f18f-qlilnd`; skip unless it says it stopped]**
- [ ] Crucible Capacitor: melee damage per Overheating stack, a stack per blow that reaches hull from a foe or its own weapons, never from overheat burn **[claimed 29 September, night: the cloud session on branch `ccr-23c2f18f-qlilnd`; skip unless it says it stopped]**
- [ ] Tactical Databank: kinetic weapons roll their maximum with an ally in the fight; needs an ally-present condition **[claimed 29 September, night: the cloud session on branch `ccr-23c2f18f-qlilnd`; skip unless it says it stopped]**
- [ ] Glacis: the Breaching Plow's armour against front-rank blows only, once the engine knows which rank struck (flat +5 today) **[claimed 29 September, night: the cloud session on branch `ccr-23c2f18f-qlilnd`; skip unless it says it stopped]**
- [ ] The planned statuses still without an engine: Phased, Beacon, Energy Armour
- [ ] The planned player keywords: Corrode, Scramble, Confuse
- [ ] The planned triggers: on shield gain, on heat gain, on round start, on skirmish start, on hull damage, out of combat **[claimed 29 September, night: the cloud session on branch `ccr-23c2f18f-qlilnd`; skip unless it says it stopped]**
- [ ] Foe roles, and the ten planned foe actions in `content/foes.json` (buff, defend and debuff kinds running; every foe status they grant fires `on_foe_status`) **[claimed 29 September, night: the cloud session on branch `ccr-23c2f18f-qlilnd`; skip unless it says it stopped]**
- [x] Buff equipment (29 September): the `buff` kind grants a machine status for so many stacks and rounds; Overcharged, Braced and Primed as the first three; the Overcharge Coil as a draft component fitted to nothing; the heat passive above can now be built on it
- [ ] Granted passives coloured on the codex
- [ ] Save and resume mid-battle at any phase (nothing is serialised yet) **[claimed 29 September, night: the cloud session on branch `ccr-23c2f18f-qlilnd`; skip unless it says it stopped]**
- [ ] Onboarding: the gesture tutorial and the cheat sheet; the reroll rule and the zone of control first
- [x] The bot values a status for the stun it may cause (29 September: `_loop_chance` in `policy.gd`, at the loop's odds and the foe's resistance) and weighs a buff by what its status does to the machine it lands on
- [ ] Rerun `tools/balance.gd` once the new machines have real kits, and after each engine piece above; read bands, not numbers

## Map and screens

- [x] The black gap between the map's frame and the log was the readout's reserved strip, empty until a hold; it now carries the orders board (`OrdersBoard`, 28 September). Ryan judges it on the phone
- [ ] The wreck's death animation on the map, once wrecks are decided
- [ ] Joint idle for grounded machines, once joints exist
- [ ] Corruption in a pack's wake, and the bleed growing with Rift Pressure (`bleed.gd` has the knob in mind), once decided
- [ ] If the phone drops frames: one mesh per material per machine, until joints
- [ ] `tools/screenshot.gd`'s engage pose prints renderer leak warnings at exit (harmless; fix if cheap)

## Art

- [x] lowforge briefs and models for the seven new machines (first passes, 29 September; every hardpoint has its pin, every fixed component is modelled in); Ryan iterates by render
- [ ] Ryan: notes on the seven second-pass models (renders: the Model Viewer, https://claude.ai/artifact/HzF8K98MxgJP7kroxAuDMv)
- [ ] Silhouette classes for components (decided 29 September): shape helpers in lowforge (barrel, twin barrel, rack, slab, vent block, dish), a validated `shape` field on every component, chassis pins parenting their stock shape so `MechView3D.mount()` hides it, and the skirmish and codex calling mount for the fitted loadout
- [ ] Ryan: judge the Baboon's rear silhouette in the harness (the fists hang at knee height now, not on the ground); if it still reads as carrying two boxes, pick heavier hands carrying hardware or a standard forward pose with the fist tile turned 90 degrees
- [ ] Enemy art through foeforge for the foes still on sketch grids
- [ ] The hangar as a model
- [ ] Per-mech repaint (`Unit.paint` exists; nothing sets it)
- [ ] A licensed icon set (game-icons.net, CC BY) rendered to textures, replacing the line-drawn glyphs in one pass

## Pages (standing, after every content change)

- [x] Joining the accounts (29 September): done. Nameplate, codex and phone sketches are shared to the work email as Editor and open there; A merged B's 42 component rows into its nameplate (an invited editor from another organisation cannot use a page's database from Claude Code, so B exported and A imported); the bible's and viewer's invites do not arrive, Ryan retries later, B keeps its own bible copy meanwhile. B's nameplate copy is deleted (29 September, night); B keeps only its bible copy and the content editor
- Republish the content editor (https://claude.ai/artifact/HnE3gvsxNHXyjRhRyEiDqT) with its `files` map, or its baselines go stale; read its files first if another session published since (a B session only: the page is B's and B cannot share outward; source `tools/content_editor.html`)
- [ ] B: republish the content editor now; `content/components.json` and `content/vocabulary.json` changed on 29 September (the buff kind, Overcharged, Braced, Primed, the Overcharge Coil) and its baselines are stale
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

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
- [ ] The Badger's joints and pins in Blender (`forge.py export badger`); the missing model pins: the Clydesdale has 6 for 9 hardpoints, the Sparrowhawk 2 for 4
- [ ] The Sparrowhawk's model carries two pins for four hardpoints (wing pods only); two more sockets, and the codex page flags both it and the Clydesdale until then
- [x] Picks from the phone sketches page: the bass voice (3 or 5), the clip-free guitar, the third shadows (28 September: voice 12, the guitar, the third cut, a quarter of the level gap; all in the forge)
- [ ] Judge the drums' last dial-in from the sketches page's "Now" set: `mix_ship` (the track as it ships), `drums_kick` (the kick's size, three steps down) and `drums_tom` (the toms, three steps tighter); say which step, or further
- [ ] Read `docs/balance.md` against your own play; then either the numbers move or the bot's next rung is built
- [ ] Discuss first, then decide: ally wrecks (block a hex? a round or the battle?)
- [ ] Discuss first, then decide: what terrain does in a skirmish (things the machines feel, never a bonus to the foes)
- [ ] Discuss first, then decide: base defences (gate guns, then turrets; `Battlefield.defenses()` is empty)
- [ ] Discuss first, then decide: the reinforcement phase, and whether skirmish composition follows placement
- [ ] Discuss first, then decide: when and how the multi-hex boss comes back (`Unit.TRIANGLE` waits)
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
- [ ] Buff equipment: a component kind spent on a machine that grants a round-scoped modifier (damage up, damage taken down, a status on hit); Overcharge as the first, then the heat passive above
- [ ] Granted passives coloured on the codex
- [ ] Save and resume mid-battle at any phase (nothing is serialised yet)
- [ ] Onboarding: the gesture tutorial and the cheat sheet; the reroll rule and the zone of control first
- [ ] The bot values a status for the stun it may cause (`policy.gd` ignores `on_foe_status`, so the Baboon's row understates it)
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
- [ ] Ryan: notes on the seven second-pass models (renders: the second-passes page in status)
- [ ] Silhouette classes for components (decided 29 September): shape helpers in lowforge (barrel, twin barrel, rack, slab, vent block, dish), a validated `shape` field on every component, chassis pins parenting their stock shape so `MechView3D.mount()` hides it, and the skirmish and codex calling mount for the fitted loadout
- [ ] Ryan: judge the Baboon's rear silhouette in the harness (the fists hang at knee height now, not on the ground); if it still reads as carrying two boxes, pick heavier hands carrying hardware or a standard forward pose with the fist tile turned 90 degrees
- [ ] Enemy art through foeforge for the foes still on sketch grids
- [ ] The hangar as a model
- [ ] Per-mech repaint (`Unit.paint` exists; nothing sets it)
- [ ] A licensed icon set (game-icons.net, CC BY) rendered to textures, replacing the line-drawn glyphs in one pass

## Pages (standing, after every content change)

- Joining the two accounts (agreed 29 September): Ryan invites the work email as Editor on each of account A's pages (bible, nameplate, renders, codex, phone sketches); a B session commits `content_editor.html` into `tools/`, applies the `edits` database, then A publishes the editor and B's copies retire
- Republish the content editor (https://claude.ai/artifact/HnE3gvsxNHXyjRhRyEiDqT) with its `files` map, or its baselines go stale; read its files first if another session published since
- Rebake the nameplate page's baked-in current names (`CURRENT` in its script) when a chassis or component is added or renamed
- Republish the bible from the committed file (each account to its own URL, listed in status)
- Regenerate the hangar codex (`python3 tools/build_codex.py . codex.html`) after a content or model change and republish it, each account to its own copy; it reads the built `.glb` files, so build and import first

## Audio

- [x] Rebuild the rift tracks on the one master (tilt 1.5 plus presence)
- [x] Land Ryan's phone-sketch picks in the forge (28 September: the driven bass, the backing guitar, the kick, the toms, the crash, the sub's shadow, the rift levels)
- [ ] A speakers or headphones setting (default speaker on a phone; Godot cannot tell what is plugged in): shipped levels for headphones, an offset per track and an EQ on the music bus for the speaker profile; discuss the offsets first
- [ ] The Risen and Infernal Horde boss themes from their seeds; melodies proposed in chat first
- [ ] The real recordings and the real track: who makes them

## Pinned, not now

- Low-hull berserker or last-stand ability
- Command die faces with a second, battlefield meaning
- Endless mode after the bounded campaign
- Hardwired hardpoints with a paid unlock (waits on the economy)

# To-do

One line per task: the specific thing to do, and what unblocks it when something does.
Grouped by who moves it. Tick a line when it lands, in the same commit as the work; the
next session prunes ticked lines. This file says only what is next. Why, and the
direction behind it, live in the bible (section 12 is the roadmap); how things stand
today lives in `docs/status.md`. "Discuss first" means a proposal in chat before code.

## Ryan

- [ ] Play-test the engagement range (`Battlefield.ENGAGE_RANGE` = 2) and the tethers; say whether formations are still wanted
- [ ] Judge on the phone after a re-export: frame rate, the sound set, the machines' edges without MSAA, the text, the grid at `GRID_GAIN_PHONE`, the seam band (less green than before), the far blur
- [ ] Codex and flavour for the seven new machines and the eighteen new components
- [ ] Decide the flagged names (`design.name_clash` notes on goshawk, dingo, sparrowhawk, the badger id)
- [ ] The Badger's joints and pins in Blender (`forge.py export badger`); the Clydesdale's nine pins
- [ ] Picks from the phone sketches page: the bass voice (3 or 5), the clip-free guitar, the third shadows
- [ ] Read `docs/balance.md` against your own play; then either the numbers move or the bot's next rung is built
- [ ] Discuss first, then decide: ally wrecks (block a hex? a round or the battle?)
- [ ] Discuss first, then decide: what terrain does in a skirmish (things the machines feel, never a bonus to the foes)
- [ ] Discuss first, then decide: base defences (gate guns, then turrets; `Battlefield.defenses()` is empty)
- [ ] Discuss first, then decide: the reinforcement phase, and whether skirmish composition follows placement
- [ ] Discuss first, then decide: when and how the multi-hex boss comes back (`Unit.TRIANGLE` waits)
- [ ] Discuss first, then decide: the economy and the blueprint tiers (nothing that prices anything can be designed before this)
- [ ] The ideas list: burning terrain, statuses carried between fights, hunter packs, hull repair
- [ ] Movespeed in tens like every other number, or in hexes as now
- [ ] Enemy targeting among machines in a skirmish (lowest shield, highest heat, last attacker, random) and how it is telegraphed
- [ ] The game's name

## Engine

- [ ] The planned pieces the 28 September content leans on, in Ryan's order: volatile, devour, Overcharged, Shocked, taunt, overwhelm, the stealth join rule, the vent-on-fire face, the die-local reroll, heat-scaled shield regen
- [ ] The planned statuses still without an engine: Phased, Beacon, Retaliate, Energy Armour
- [ ] The planned player keywords: Overwhelm, Corrode, Scramble, Confuse
- [ ] The planned triggers: on shield gain, on heat gain, on round start, on skirmish start, on hull damage, out of combat
- [ ] Foe roles, and the ten planned foe actions in `content/foes.json`
- [ ] Granted passives coloured on the codex
- [ ] Save and resume mid-battle at any phase (nothing is serialised yet)
- [ ] Onboarding: the gesture tutorial and the cheat sheet; the reroll rule and the zone of control first
- [ ] Rerun `tools/balance.gd` once the new machines have real kits, and after each engine piece above; read bands, not numbers

## Map and screens

- [ ] Close the black gap between the map's frame and the log on a tall screen (the map view grows with the glass; its frame does not fill it)
- [ ] The wreck's death animation on the map, once wrecks are decided
- [ ] Joint idle for grounded machines, once joints exist
- [ ] Corruption in a pack's wake, and the bleed growing with Rift Pressure (`bleed.gd` has the knob in mind), once decided
- [ ] If the phone drops frames: one mesh per material per machine, until joints
- [ ] `tools/screenshot.gd`'s engage pose prints renderer leak warnings at exit (harmless; fix if cheap)

## Art

- [ ] lowforge briefs and models for the seven new machines; a mount for every new component
- [ ] Enemy art through foeforge for the foes still on sketch grids
- [ ] The hangar as a model
- [ ] Per-mech repaint (`Unit.paint` exists; nothing sets it)
- [ ] A licensed icon set (game-icons.net, CC BY) rendered to textures, replacing the line-drawn glyphs in one pass
- [ ] The content editor's review page still says Mandrill; it is the Baboon

## Audio

- [ ] Rebuild the rift tracks on the one master (tilt 1.5 plus presence)
- [ ] Land Ryan's phone-sketch picks in the forge; then a speakers or headphones setting
- [ ] The Risen and Infernal Horde boss themes from their seeds; melodies proposed in chat first
- [ ] The real recordings and the real track: who makes them

## Pinned, not now

- Low-hull berserker or last-stand ability
- Command die faces with a second, battlefield meaning
- Endless mode after the bounded campaign
- Hardwired hardpoints with a paid unlock (waits on the economy)

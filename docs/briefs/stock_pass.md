# Brief: the stock pass (the plan and the proposal)

The one home for the stock pass: the scale's tests and first fills, every piece's tags, tier,
number and heat, each chassis's stock and armour, the breach's carriers, the engine spec, the
method and the chunks. Ryan marks the proposal; the engine chunk runs meanwhile; the content
lands on his marks. Decisions are the bible's rows (sections 2, 5, 6 and 11, 22 October); this
brief holds the fills and the plan, and retires to git when the pass lands.

**Status**: landed 22 October (the content, the loops' numbers, the bands at 200 seeds; the plan and proposal of the same day beneath); open for Ryan's reads (the bible's section 12), the name pass and the pricing run, then it retires to git.
**Maker**: all. **Read first**: `docs/briefs/README.md`; the bible's scales row (section 11),
its kill-time row (section 2), its armour, breach and heat rows (section 5), its HP row
(section 6), its stock-pass and tiers rows (sections 7 and 10); `docs/rules.md`;
`content/components.json`, `content/chassis.json`, `content/foes.json`, `content/modules.json`;
`docs/briefs/kestrel_line.md` (the Buzzard's and the Puffin's kits, Kestrel's three pieces);
`docs/briefs/aphelion_baboon.md` (the Inducer's gate); `docs/balance.md` (13 October, the
before).

## What Ryan said (21 and 22 October)

- "Ignore existing content for a second while we evaluate these numbers, because those hull
  numbers sound very high to me compared to the damage numbers." "Let's not make any
  assumptions based on existing content for any number, whether that's heat, damage, armor,
  shield, or health on both sides of the field."
- "I'd like to change our verbiage so that enemies use HP instead of hull."
- "One to two for rank and file makes sense. I feel like the larger enemies might need more
  hits to account for an actual semi-optimized team that isn't just attacking blindly."
  "Four hard fights might be okay ... we can keep that for now and just see how the runner
  does." "I'd like to keep heat at 1 to 20 ... 1 to 30 is fine as well if heat seems
  unbalanceable."
- "I wouldn't price armor based on chassis size. I would price it based on role." Flat
  reduction stays; "armour numbers that are only reachable conditionally should allow complete
  blocks"; the half, calibre and square rules are retired (the armour row names each and its
  test). "I'd rather introduce flat armour penetration to certain enemies and keep the math
  simple": one breach, ignoring shield and armour, by move (the breach row).
- "I do like the numbers in general. They are readable to a person. So I think that we should
  work with this for now." And on the whole: "Ok. I like it, lock it in."
- Open from the same days (section 12): Overcharged's and Flak's halving clock, kept or
  unified; whether our guns take Breach.

## 1. The scale

**The tests** (the bible's row, section 2). Rank and file die to one good blow or two ordinary
ones; a massive foe takes a team a round or two of focus, a boss three to five; on the big foes
a coordinated round (a Shock under the hitter, Flak under the rest, area on a bunched row) kills
in about half the rounds a blind one does, and on trash there is no gap; a machine fought
through about four hard fights unwithdrawn is worn, not wrecked; a hot kit overheats by its
third round of firing without a vent (the heat row).

**The magnitudes.** A blow 1 to 6, big guns to 10, one capstone 12; an amp a point a stack;
foe HP 2 to 6 rank and file, 30 to 40 massive, 12 to 24 heroes, 80 to 100 bosses; a foe's
blow 1 to 6, a boss's 6 to 10; machine hull 20 to 50 by size, shield 6 to 16, field recharge
6 to 10, base armour 0 to 2 by role, timed armour to 4 or 5; heat 1 to 20, the maxima 12 to
20, cooling 0 to 2, a gun 0 (cold), 1 (cool), 2 (warm), 4 (hot), 6 or 8 (very hot), a vent
3 to 8. Heat classes by niche: a rolled basic is cold or cool, a flat basic warm, a keyword
piece warm to hot, a big flat gun very hot; a Rapid piece pays heat as its price.

**The paper model behind the HP fills.** A blind round is four blows of about 3.5, each less
the foe's armour; a coordinated round spends one die on a Shock cashed by the hitter and one
on Flak the rest fire through. Rounds to kill: six goblins 2 and 2; a Treant at 30 and armour
1, 3 and 2; a Sandworm at 36 and armour 2, 6 and 3; a boss at 90 and armour 2, 15 and 5 to 7.
At a Sandworm of 24 the gap read 3 against 2, no room, which is why the massive fills sit at
30 to 40. The runner reads the same gap as rounds to win, blind play against the planner
(section 7).

**The fills measured** (22 October, a direction at 30 seeds, every row against every pack,
`docs/measurements.md`): the rank and file die to a die or two; a massive foe takes a team
three to twelve rounds, not one or two, and four machines alone stall on the Treant's regrow;
the gap stays at the baseline's one and a half everywhere, the one-round bot unable to show
it; a team loses a per cent of its hull to trash and a tenth to a fifth to a massive foe; heat
bites on five kits and not the rest. Every team wins every pack but the finale, the random
rung included, since the old numbers were divided unevenly (our durability by four, the foes'
blows by five to six, the rank and file's HP by eight to ten). The levers the marks should
move are in the entry: the foes' blows up by half to double or our hull and shield down a
quarter, cooling 0 with the typical gun at 2 to 4, the massive elites' armour 1, the regrows
at 3.

### Every converter on its own

Each is a first fill for the reason given, never a ratio carried over.

| Converter | Today | First fill | Reason |
|---|---|---|---|
| Overheat, hull per heat point over | 1 for 1 | 1 for 1 | hull runs about twice the heat maximum, as now; a hot gun over the top costs a third of a light machine |
| Volatile's bite | 10 hull | 3 hull | about a tenth of a machine |
| The Whip Scorpion's blast | the heat vented | the heat vented | heat and damage share a magnitude now, so a vent of 6 blasts 6: a rank-and-file kill or a quarter of a massive foe |
| The Afterburner's vents-all | +10 per 10 heat fired | +1 per 2 heat fired | a full gauge adds 8 to 10, a capstone blow once a fight |
| The Buzzard's Thermal Recoupler | 5 shield per 10 heat carried | 1 shield per 4 heat carried | the honest shield row said the regen becomes hit points; half of heat as shield was the whole-block shield's number |
| The Puffin's Slipstream Projector | a fifth of the ally's heat | 1 shield per 2 heat the ally carries | the hottest ally at the top of its gauge gets about a full shield, the row's feel; 1 per 3 the lever |
| The Musk Ox's Desublimation Forge | 1 ammo per 10 heat | 1 ammo per 2 heat, at least 1 | Ryan's 2, given at this scale; guns run 0 to 8 |
| Cryo | cools 10 a stack | cools 2 a stack | a cool gun's heat |
| Burning on a machine | 5 heat a stack | 1 heat a stack | mirrors the foe's 1 damage a stack; closes section 12's question |
| Scorched | +5 heat a weapon fired | +1 | |
| Siphoning | +10 heat a blow landed | +2 | four blows fuel a vent of 8 |
| Sealed | armour +10, 15 heat a turn | armour +3, 3 heat a turn | a wall to 5 that holds about five turns from cold |
| The Stingray's Exothermic Suite | a stack per 20 heat carried | a stack per 5 heat | |
| The hot-machine threshold (foes' conditions and aim) | 20 heat | 5 heat | about a third of a typical maximum |
| Vitriol | 5% of current HP a stack | 10% | 5% of a 24 HP massive foe is 1, below a blow; it never finishes a foe and rounds to nothing on trash either way |
| Missing HP | +N per 20 hull missing | +N per 5 HP missing | a finisher on massive foes |
| The hopper | +5 a load | +1 a load | |
| Kindled | +10 (Stoke), +5 (Howl) | +2, +1 | a rally lifts a goblin's 1 over a tank's plate |
| The Cottonmouth's drum | flat 15, heat 10 | flat 4, heat 3 | over cooling 2 so it heats (its row's lean) |
| The Kite's heat tax and Hot Streak (its rework, on the Kestrel branch) | +10 heat a shot; 5 hotter a kill | +2 a shot; 1 hotter a kill | the flat tax answers the cool-gun abuse at any scale |

### Stack counts and the clocks

Halving rounds down, so a grant of 1 lasts the round, 2 two rounds, 4 three. Burning fades a
stack an action: Burn 2 is 3 over two actions, Burn 3 is 6. For a single grant of 1 or 2 the
halving and a stack a round are the same clock; they part on repeated feeds (section 12).

| Status | Today | First fill |
|---|---|---|
| Burn on the 10-damage pieces / the 15s | 3 / 5 | 2 / 3 |
| Flak, the Flakshot / the Recuperator | 2 / 1 | 2 / 1 (the Flakshot's blow at 1, so the gun is the amp; 1 the lever) |
| Overcharged, the Coil / the Talons a kill / the Reliquary a hull hit | 2 / 2 / 1 | 1 / 1 / 1 |
| Spun Up, a stack | +5 | +2 |
| Armoured, the Shoring Jack / the Plow's brace / the Conjugator a shield | 10 / 10 / 3 | 3 / 2 / 1 |
| A foe's brace | its value in stacks | 2 or 3, so a braced massive foe stands at 4 or 5 |
| Numbed, Paradox, the rerolls, the injury quarter | unchanged | unchanged: counts and shares |

### The engine's constants that become content or fields

| Constant | Where | Today | Fill |
|---|---|---|---|
| `CRYO_COOL_PER_STACK` | `sim/skirmish.gd` | 10 | 2 |
| `HOT_HEAT` | `sim/skirmish.gd` | 20 | 5 |
| `VOLATILE_BITE` | `sim/skirmish.gd` | 10 | 3 |
| `DANGER_CLOSE_DIVISOR` and the splash | `sim/skirmish.gd` | 2 | gone (danger close retires) |
| `burning_mech` tick_heat, `scorched` add_heat | `Effects.STATUS` | 5, 5 | 1, 1 |
| `siphoning` and `kindled` defaults | `Effects.STATUS` | 10, 10 | 2, 2 (the content's own numbers rule) |
| `vitriol` tick_hp_share | `Effects.STATUS` | 5 | 10 |
| `MISSING_STEP` | `sim/face.gd` | 20 | 5 |
| `power_per_heat` per 10 | `Skirmish.heat_bonus`, `Policy` | `int(heat / 10)` | a `per_heat` on the face, the Afterburner's 2 |
| `shield_per_heat` per 10 | `Effects` (line 1156) | `int(amount / 10)` | the effect's `per_heat`, the Buzzard's 4 |
| `shield_per_ally_heat` | the Puffin's passive | value 2 per 10 | value 1, `per_heat` 2 |
| `add_stacks` `per_heat` | the Stingray's passive | 20 | 5 (a field already) |
| `seal_form` value and heat | the Armadillo's passive | 10, 15 | 3, 3 (fields already) |
| The bot's absolute weights | `sim/policy.gd` | `KILL_BONUS` 10, `DEATH_WEIGHT` 60 in foe hit points | about 3 and 20; the share weights (`HULL_WEIGHT`, `FLAK_WEIGHT`, `FUEL_WEIGHT`, ...) stand |
| The map and the campaign | `sim/battle*.gd`, `sim/campaign.gd` | the gate 200 and 300, salvage 10 a kill, Favour 100, the bleed 50 and 25 | unchanged: another economy (the economy pass) |

## 2. The chassis

Base armour by role, not size (Ryan): a tank 2, a heavy worker 1, a car, a hover, a flyer or
a glass cannon 0; the braces, the seal and the charge add 2 or 3 for a round. Field recharge
is shield back a map turn out of fights. Every tier-one chassis stocks basics beside its
locked piece; a tier two stocks tiers 0 and 1; a tier three stocks 0 to 2 (the tiers row).

| Chassis | Maker | Tier | Today: hull, shield, recharge, heat, cooling, armour | First fill | Role, the armour's reason | Stock proposal | Note |
|---|---|---|---|---|---|---|---|
| Honey Badger | Minerva | 1 | 160, 30, 15, 80, 5, 10 | 36, 8, 4, 16, 1, 2 | tank, Minerva | Rivet Gun, Blast Door, Coolant Jacket | the Blowout Stack retires; the Jacket in its slot |
| Clydesdale | Wainwright & Sutler | 2 | 140, 40, 20, 60, 5, 5 | 40, 10, 5, 16, 1, 1 | heavy worker | Maxigun, Twin Autoguns, Enfilade Beam, Ankle Mortar, Howitzer, Airburst Shell (a working name), Blast Door, Incendiary Shells, Coolant Jacket | the Suppression Battery, tier two, leaves; the Airburst Shell takes its slot |
| Kite | Kestrel | 2 (its rework, built on the Kestrel branch, 21 October; main still carries tier one) | 60, 60, 30, 60, 0, 0 on main; 30, 40, 30, 40, 10, 0 after its rework | 12, 16, 8, 10, 2, 0 | glass cannon, flyer | after the rework a d3: the Pinion Driver locked and two hardpoints, the Transonic Rifle and the renamed Kestrel vent | the rework's heat tax of 10 a shot becomes 2 and Hot Streak's 5 hotter a kill becomes 1; on main's tier-one Kite until the branches merge: the Laser Carbine, the Twin Autoguns, the renamed self shield and the renamed vent |
| Baboon | Aphelion | 1 (2 with its session) | 100, 40, 20, 80, 5, 0 | 28, 10, 5, 20, 1, 0 | support | Twin Autoguns, Laser Carbine, Halo Shield, Coolant Jacket, Rivet Gun, Ankle Mortar | tier one until its session; it may stock a shield again (the Halo); the Inducers leave the stock for the pool at tier two |
| Armadillo | Minerva | 1 | 150, 30, 15, 60, 5, 5 | 40, 8, 4, 16, 1, 2 | tank | Rivet Gun, Twin Autoguns, Blast Door, Ram-air Scoop | the seal +3 armour and 3 heat a turn, its cooling stopped: a wall to 5, about five turns from cold |
| Wild Boar | Minerva | 2 | 130, 30, 20, 60, 5, 10 | 36, 8, 5, 16, 1, 2 | tank-brawler | Slugthrower, Slugthrower, Shotfire Rack, Blast Door, Coolant Jacket | the Blowout Stack retires; the Jacket in its slot |
| Prairie Dog | Wainwright & Sutler | 1 | 60, 40, 30, 60, 5, 0 | 16, 10, 8, 16, 1, 0 | car | Twin Autoguns, Halo Shield, Coolant Jacket | the basic shield: the Halo, self or ally, so the car shields the ally it skims past (Claude's pick; section 12 asked) |
| Dingo | Wainwright & Sutler | 2 | 60, 40, 25, 60, 5, 0 | 16, 10, 6, 16, 1, 0 | car, team piece | Airburst Shell (a working name), Twin Autoguns, Coolant Jacket | a Flak layer beside its Shocking harpoon, the maker's two amps on one die |
| Buzzard | Kestrel | 2 | 100, 50, 25, 100, 5, 0 | 28, 12, 6, 20, 1, 0 | hot flyer | Overclocked Railgun, Transonic Rifle, Arc Fault Cannon, Blast Door, Ram-air Scoop | the Buzzard, as the Kestrel line filled it; regen 1 shield per 4 heat carried |
| Nemesis | the Arsenal | 2 | 140, 20, 15, 100, 5, 10 | 36, 6, 4, 20, 1, 2 | bruiser | Plasma Arquebus, Blazethrower, Retribution Thurible, Oblation Mantle | the Arsenal's tier-one pieces, so its stock keeps the maker's voice: the Thurible and the Mantle come down to tier one for it |
| Ammit | the Arsenal | 3 | 120, 40, 20, 80, 5, 5 | 32, 10, 5, 20, 1, 1 | heavy worker | Plasma Arquebus, Blazethrower, Oblation Mantle, Entropy Condenser | as today |
| Stingray | Aphelion | 1 | 80, 50, 25, 100, 0, 0 | 24, 12, 6, 20, 0, 0 | hot support hover | Laser Carbine, Halo Shield, Coolant Jacket, Twin Autoguns, Ankle Mortar | the Zenith folds into the Carbine; the shells, the Lattice and the Sail become found |
| Puffin | Kestrel | 1 | 50, 30, 30, 60, 5, 0 | 16, 8, 8, 16, 1, 0 | escort | Halo Shield, Coolant Jacket, Twin Autoguns, Laser Carbine | as the Kestrel line filled it; the Coil, the Diffuser and the Carbine become found upgrades (the Carbine stays as its basic gun) |
| Funnel-web | Wainwright & Sutler | 2 | 110, 40, 20, 60, 5, 5 | 30, 10, 5, 16, 1, 1 | heavy worker | Maxigun, Howitzer, Twin Autoguns, Blast Door | the Deflector leaves (a tier-two blueprint); the self shield in its slot |
| Cassowary | Wainwright & Sutler | 1 | 80, 30, 20, 60, 5, 0 | 24, 8, 5, 16, 1, 0 | glass cannon | Twin Autoguns, Rivet Gun, Ankle Mortar, Halo Shield, Coolant Jacket | squishy on purpose (its row) |
| Cottonmouth | Wainwright & Sutler | 1 | 60, 30, 30, 60, 10, 0 | 16, 8, 8, 16, 2, 0 | reach piece, hover | Ankle Mortar, Twin Autoguns, Halo Shield, Coolant Jacket | the drum: Indirect, flat 4, heat 3 over cooling 2, so it heats |
| Whip Scorpion | Wainwright & Sutler | 2 | 150, 30, 15, 100, 0, 10 | 40, 8, 4, 20, 0, 1 | sustained dealer | Thermal Ray, Coolant Jacket, Coolant Jacket, Maxigun | cooling 0 by design; the Thermal Ray at tier one so it may stock it |
| Swallowtail | Wainwright & Sutler | 3 | 200, 60, 20, 80, 10, 5 | 48, 14, 5, 20, 2, 1 | carrier, assault flyer | Howitzer, Twin Autoguns, Blast Door | as today, the self shield renamed |
| Musk Ox | Wainwright & Sutler | 3 | 160, 40, 20, 30, 5, 10 | 44, 10, 5, 8, 1, 1 | artillery; the magazine 10 | Thermal Ray, Enfilade Beam, Coolant Jacket, Blast Door | its heat bar is low by design; its guns pay ammo, 1 per 2 heat |

## 3. The components

Tags from the working set (Ballistic, Missile, Beam, Plasma, Flame, Arc, Blade, Melee), by
each piece's fantasy, shown in the codex only; equipment mostly wears none (the line frame's
shield beam waits on its model session). Melee is short range, a sawed-off cannon included.
Tiers: 0 the basics, every blueprint a run starts with; 1 to 3 found or brought by a bought
chassis; a fixed piece has none. Numbers at the new scale by niche.

### The basic kit, tier zero

Eight pieces, two shapes of gun, two shields, two vents, each a maker's. The names of the two
renamed pieces are Ryan's; working names below.


| Piece | Maker | Tier | Today | First fill | Keywords and rules | Tags | Note |
|---|---|---|---|---|---|---|---|
| Twin Autoguns | Wainwright & Sutler | 0, a basic | 5 to 15, heat 0 | 1 to 3, heat 0 |  | Ballistic | the basic rolled Direct gun |
| Rivet Gun | Minerva | 0, a basic | 5 to 15, heat 0 | 2, heat 0 |  | Ballistic | the basic flat Direct gun; a basic on the Armadillo (the stock-pass row) |
| Ankle Mortar | Wainwright & Sutler | 0, a basic | 5 to 15, heat 0 | 1 to 3, heat 1 |  | Ballistic | the basic Indirect gun |
| Laser Carbine | Kestrel | 0, a basic | 10, heat 5 | 3, heat 2 |  | Beam | the warm basic: reliable 3 for heat; the Zenith Emitter folds into it |
| Halo Shield | Aphelion | 0, a basic | 20 | 6 | self or ally | none | the basic shield; the Prairie Dog's and the Puffin's (section 12 asked which) |
| Blast Door | Minerva | 0, a basic | 20 | 8 | self only | none | renamed: the name moves to the Barrier piece below; Minerva's basic self shield (the Buzzard's stock) |
| Coolant Jacket | Wainwright & Sutler | 0, a basic | 20 | 4 | self or ally | none | the basic vent; keeps its name |
| Ram-air Scoop | Kestrel | 0, a basic | 20 | 6 | self only | none | renamed; Kestrel's basic self vent, the jet's brake |

Renames (working names, Ryan, 22 October: "go with your name suggestions, I'll do a content
name pass later"): the Minerva self shield (today the Blast Door) becomes the **Canopy**, the
falling-object guard on a mining machine, so that "Blast Door" is free for the Barrier piece
whose fantasy it already is (the Barrier row); the Kestrel self vent (today the Ram-air Scoop,
which collides with the Ram Frame module) becomes the **Bleed Valve**.

### Tier one


| Piece | Maker | Tier | Today | First fill | Keywords and rules | Tags | Note |
|---|---|---|---|---|---|---|---|
| Howitzer | Wainwright & Sutler | 1 | 10 to 25, heat 0 | 2 to 5, heat 1 |  | Ballistic | the bigger Indirect roll |
| Incendiary Shells | Wainwright & Sutler | 1 | 5 to 15, heat 0 | burn | 1 to 3, heat 1 | Burn 2 | Ballistic, Flame | Burn 3 today; the hull scale moved |
| Slugthrower | Minerva | 1 | 15 to 30, heat 10 | 2 to 5, heat 1 |  | Ballistic | the old close weapon down to Direct's band; the Boar's pair |
| Shotfire Rack | Minerva | 1 | 10 to 20, heat 10 | 2 to 4, heat 2 |  | Missile |  |
| Maxigun | Wainwright & Sutler | 1 | 5 to 10 ×3, heat 5 | 1 to 2 ×3, heat 1 |  | Ballistic | the multi-strike basic; strikes of 1 bounce off any plate, Flak lifts them |
| Enfilade Beam | Wainwright & Sutler | 1 | 15, heat 10 | penetrate | 4, heat 2 | Penetrate | Beam | the column gun |
| Arc Fault Cannon | Kestrel | 1 | 15, heat 10 | chain | 4, heat 2 | Chain | Arc | Chain whatever Chain becomes (section 12) |
| Overclocked Railgun | Kestrel | 1 | 50, heat 40 | 10, heat 8 | Breach (Ryan, 22 October) | Ballistic, Arc | the big hot flat gun, kept (the Kestrel line); a whole gauge a shot; the one gun that breaches |
| Plasma Arquebus | the Arsenal | 1 | 5 to 15, heat 5 | 2 to 4, heat 2 |  | Plasma | the Arsenal's tier one |
| Blazethrower | the Arsenal | 1 | 10, heat 10 | burn | 3, heat 3 | Burn 2 | Flame, Plasma |  |
| Polarity Projector | Aphelion | 1 | 0, heat 5 | shock | 0, heat 2 | Shock | Arc | the tier-one Shock, a brace's answer |
| Proximity Klaxon | Minerva | 1 | 0, heat 0 | lure, cleave | 0, heat 1 | Lure, Spread | Arc | out of Misharu's stock (its brief) |
| Phased Sublimator | Aphelion | 1 | 20 | cleanse | 4 | Cleanse; self or ally | none | the cleanse vent |
| Radiator Sail | Aphelion | 1 | 20 | 5 | ally only | none | from a basic to Aphelion's ally vent, so three basic vents become two |
| Wake Diffuser | Kestrel | 1 | 10 | 3, shields 3 | self or ally | none | the combined entry; its shield half built 21 October |
| Overcharge Coil | Kestrel | 1 |  | Overcharged 2 | self or ally | none | 2 (Ryan, 22 October): at 1 the halving leaves +1 on one ally's blow this round and nothing after |
| Shoring Jack | Minerva | 1 |  | Armoured 2, the round | self or ally | none | 2 at tier one (Ryan, 22 October): a tank to 4 for the round; 3 would wall everything but a boss from a tier-one piece |
| Thermal Ray | Wainwright & Sutler | 1 | 30, heat 30 | 6, heat 6 |  | Beam | the hot flat gun; tier one so the Whip Scorpion and the Musk Ox may stock it ("the Thermal Ray's heat price") |
| Transonic Rifle | Kestrel | 1 | new | 5, heat 4 |  | Ballistic | new (the Kestrel line): the step between the Carbine and the Railgun |
| Airburst Shell (a working name) | Wainwright & Sutler | 1 | new | 1 to 2, heat 1 | Spread, Flak 1 | Ballistic | new, the Flak family (Ryan, 19 October): the slot-in above the basics |
| Retribution Thurible | the Arsenal | 1 |  | Retaliate, 2 rounds | self or ally | none | to tier one so the Nemesis may stock it; the echidna's change pending (its brief) |
| Oblation Mantle | the Arsenal | 1 | 40 | volatile | 10 | Volatile; self or ally | none | the Oblation Mantle: to tier one so the Arsenal's tier twos keep an Arsenal shield; Volatile bites 3 |

### Tier two


| Piece | Maker | Tier | Today | First fill | Keywords and rules | Tags | Note |
|---|---|---|---|---|---|---|---|
| Pulse Vacillator | Aphelion | 2 | 5, heat 5 | rapid | 2, heat 2 | Rapid | Beam | heat the Rapid's price (the action-economy row): a chain of two costs 4 |
| Differentiation Probe | Aphelion | 2 | 0, heat 5 | disrupt | 0, heat 2 | Disrupt | Beam |  |
| Tesla Gauntlets | Minerva | 2 | 15, heat 10 | shock | 4, heat 3 | Shock | Arc, Melee |  |
| Meteor Artillery | the Arsenal | 2 | 15, heat 15 | burn | 5, heat 6 | Burn 3 | Plasma, Missile | Burn 5 today |
| Suppression Battery | Wainwright & Sutler | 2 | 15 to 25, heat 20 | suppress | 1 to 3, heat 2 | Suppress a foe carrying Flak (Ryan, 22 October: the maker's condition; no back-rank clause) | Ballistic | low on purpose, Claude's fill, since the target carries Flak (Flak 1 makes it 2 to 4, Flak 2 3 to 5) and a stun's damage is incidental; the cooldown gone (a cooldown is no price for a Suppress: the stun row, Ryan, 17 October); out of the Clydesdale's stock, since no stock holds a Suppress piece (Ryan, 22 October) |
| Coriolis Accelerator | Kestrel | 2 | 10, heat 0 | 3, +1 per 5 HP missing, heat 1 |  | Arc | to the pool from the Kite's and the Buzzard's stocks (the stock-pass row) |
| Laminar Deflector | Kestrel | 2 | 20 | rapid | 6 | Rapid; self or ally | none | a tier-two blueprint, out of the tier-one and tier-two stocks (Ryan, 20 October) |
| Corona Shield | Aphelion | 2 | 20 | cleanse | 6 | Cleanse; self or ally | none |  |
| Aurora Lattice | Aphelion | 2 |  | Primed 1, a round | self or ally | none |  |
| Entropy Condenser | the Arsenal | 2 | 40 | volatile | 10 | Volatile; self or ally | none | Volatile bites 3 |
| Cyclic Cannon | Kestrel | 2 | new | 2 ×4, heat 3 |  | Ballistic | new (the Kestrel line): the multi-strike gun, Flak's partner, the strafer's ×8 |
| Flak Cannon (a working name) | Wainwright & Sutler | 2 | new | 3, heat 2 | Flak 2 | Ballistic | new, the Flak family: the single-target layer for the Maxigun to chew |
| the Stoker (Ryan's word) | Wainwright & Sutler | 2 | new | 3, heat 1 | Burn 2; Burning 1 on its own firer | Flame, Ballistic | new (Ryan, 19 October): slow fuel for the Whip Scorpion by decision; the firer's stack is 1 heat at the turn's end |
| Backdraft Charge | the Arsenal | 2 | new | 2, heat 2 | consumes every stack of Burning on the foe it hits: +1 a stack consumed, and Suppress at 2 or more consumed | Plasma, Flame | new (Ryan, 22 October: the fire-synergy stun; the name stands; it consumes the fire, and his direction the same day: damage per stack consumed and the Suppress at a threshold on one piece, one burn consumer in the pool rather than two; the threshold at 2 and the numbers Claude's fills, so one Burn 2 piece opens it and no all-in burn team is needed); in no stock, like every Suppress piece |

### Tier three


| Piece | Maker | Tier | Today | First fill | Keywords and rules | Tags | Note |
|---|---|---|---|---|---|---|---|
| Gravity Knuckles | the Arsenal | 3 | 15, heat 10 | burn | 5, heat 4 | Burn 3 | Plasma, Melee | shelved (section 12) |
| Umbra Inducer | the Arsenal | 3 | Aphelion's; 10, heat 10 | suppress | 3, Volatile, heat 0 | Suppress, Volatile; no condition | Plasma | Ryan, 22 October: the Arsenal's (it reads as Arsenal tech), priced in Volatile in place of heat, tier three for its power; found and never stocked, since no chassis stocks tier three; Volatile bites 3 |

### Fixed pieces, by chassis

No tier, never a blueprint. Their numbers move with the scale like any other.


| Piece | Maker | Tier | Today | First fill | Keywords and rules | Tags | Note |
|---|---|---|---|---|---|---|---|
| Chainsaw Claw | Minerva | fixed | 10 to 20, heat 0 | cleave | 2 to 4, heat 0 | Spread; fills the hopper | Blade, Melee | the Badger |
| Bullion Fragmenter | Minerva | fixed | 20, heat 10 | 4, +1 a load, three loads, heat 2 | fires the hopper | Ballistic, Melee | the Badger |
| Breaching Plow | Minerva | fixed | 15 to 30, heat 0 | cleave | 2 to 5, heat 0 | Spread; braces 2 | Blade, Melee | the Boar: Armoured 2 for the round, a tank at 4; the first wall to measure |
| Cryo Flinger | Minerva | fixed | 0, heat 5 | lure, rapid, cryo | 0, heat 1 | Lure, Rapid, Cryo 1 | Missile | the Armadillo |
| Flakshot Repeater | Wainwright & Sutler | fixed | 5, heat 0 | cleave, flak | 1, heat 0 | Spread, Flak 1 | Ballistic | the Prairie Dog: the gun is the amp, not the damage; Flak 1 (Ryan, 22 October: 2 laid every round settles at a steady 3), 2 the lever |
| Megataser Harpoon | Wainwright & Sutler | fixed | 5 to 10, heat 10 | shock | 1 to 2, heat 2 | Shock | Ballistic, Arc | the Dingo |
| Combat Translocator | Wainwright & Sutler | fixed | 0, heat 5 | swap | 0, heat 1 | Swap | Arc | the Dingo |
| Afterburner Cannon | Kestrel | fixed | 10, heat 0 | 2, +1 per 2 heat fired, heat 0 | vents all | Plasma | the Buzzard: a full gauge adds 8 to 10 |
| Backwash Ionizer | Kestrel | fixed | 10 | overshield | 3, +1 per 2 heat the ally carries | Overshield; ally only | none | the Puffin: the hottest ally near a full shield; 1 per 3 heat the lever |
| Web Bomb | Wainwright & Sutler | fixed | 0, heat 0 | web | 0, heat 1 | Web | Missile | the funnel-web |
| Heliographic Siphon | Wainwright & Sutler | fixed | 0, heat 0 | lure | 0, heat 0 | Lure all; Armoured 1; Siphoning 2 a blow landed | Beam | the Whip Scorpion |
| Solar Flare Array | Aphelion | fixed | 10, heat 10 | burn | 3, heat 3 | Burn 2 | Plasma, Flame | the Baboon |
| Photosphere Lance | Aphelion | fixed | 10, heat 20 | burn | 4, heat 6 | Burn 2 | Beam, Flame | the Stingray: very hot, its Suite feeds on it |
| Knuckle of Fury | the Arsenal | fixed | 15, heat 10 | 5, heat 3 | rolls again on Rage | Melee, Plasma | the Nemesis |
| Soulcutter Talons | the Arsenal | fixed | 10, heat 5 | 3, heat 1 | Overcharged 1 a kill | Blade, Melee | the Ammit; 2 a kill today |
| Spin-Up | Wainwright & Sutler | fixed |  | rapid | Spun Up 1 (+2) | Rapid, spins | none | the Cassowary; +5 a stack today |
| Mooring Screens | Wainwright & Sutler | fixed | 10 | 2 to every ally; charged: Phased | planned | none | the Swallowtail |
| Spotting Flare | Wainwright & Sutler | fixed | 0, heat 0 | 0; charged: Suppress too, heat 1 | Expose; planned | Missile | the Swallowtail |
| Sutler's Hoist | Wainwright & Sutler | fixed | 15 | 3, vents 2; charged: full, cleanse | planned | none | the Swallowtail |
| Reveille Horn | Wainwright & Sutler | fixed |  | Rallied; charged: an ally acts again | planned | none | the Swallowtail |
| Shrapnel Recuperator | Wainwright & Sutler | fixed | 5, heat 10 | cleave, penetrate, flak | 1; 1 ammo a shot, 1 back a foe hit | Spread, Penetrate, Flak 1; planned | Ballistic | the Musk Ox |
| Unrestricted Expenditure | Wainwright & Sutler | fixed | 5, heat 0 | cleave, penetrate | 2 a strike, one per ammo, random | Spread, Penetrate; planned | Ballistic, Missile | the Musk Ox |
| Quick Reload | Wainwright & Sutler | fixed | 0, heat 15 | rapid | +2 ammo, heat 3 | Rapid; planned | none | the Musk Ox |

### Retired


| Piece | Maker | Tier | Today | First fill | Keywords and rules | Tags | Note |
|---|---|---|---|---|---|---|---|
| Zenith Emitter | Aphelion | retired | 15, heat 10 |  |  | none | folds into the Laser Carbine; its idea returns as a tier-three Aphelion piece (the stock-pass row) |
| Coolant Dump | Wainwright & Sutler | retired | 30 |  |  | none | retired (the stock-pass row) |
| Blowout Stack | Minerva | retired | 20 |  |  | none | retired (the stock-pass row) |

### New pieces for the stock

The Flak family and the Stoker are Wainwright & Sutler's (Ryan, 19 October, proposed here for
his marks); the Cyclic Cannon, the Transonic Rifle and Trim Tabs are Kestrel's, taken in the
line review (21 October, `kestrel_line.md`). Barrier and Ward carriers: **Blast Door**
(Minerva, tier one, a buff: Barrier on one machine, self or ally) and the **Decoherence
Veil**, Aphelion's, at tier one (a buff: Ward on one machine; a working name, the Votive Screen
being Misharu's). Neither is ever a team buff (the Barrier row).

### Our guns and Breach

Decided (Ryan, 22 October): the Overclocked Railgun carries Breach, alone, the one big flat gun
whose fantasy is armour piercing, so a Golem has an answer beside the biggest blow; the
Transonic Rifle stays a plain step in the 3, 5, 10 ladder. Foes carry no shield, so on our
side Breach ignores a foe's armour and nothing else, the same rule.

### The stuns, the Ram Frame and the Rangefinder

Decided (Ryan, 22 October; the bible's stun row): no Suppress piece sits in any chassis's
stock, the Baboon's least of all ("no reason for it to be able to stock a suppress that powers
a suppress, that should be a build choice the player has to make"), and none below tier two,
both by reason rather than cap. The slottable stuns split by gate, a Volatile stun and a fire
stun being two pieces. The Umbra Inducer is the Arsenal's (it reads as Arsenal tech to him), a
Suppress with no condition priced in Volatile in place of heat, at tier three for its power
("probably"), so it is found and never stocked. The Backdraft Charge (Ryan: the name stands)
is the tier-two fire-synergy stun, a consumer: Direct, a low base, it consumes every stack of
Burning on the foe it hits, deals a point more for each stack consumed, and Suppresses the foe
if it consumed two or more (Ryan's direction, 22 October, after agreeing that the stun puts
the fire out: damage per stack and the stun at a threshold on one piece, so the pool carries
one burn consumer rather than two; the threshold at two is Claude's fill, so any one Burn 2
piece opens it and no all-in burn team is needed, as he asked). Each stun trades the fire's
remaining ticks for the turn of safety and a lit boss is relit between stuns; a plain gate
would have left one Burn 3 holding it open three rounds with Numbed the only brake. The
Suppression Battery stays Wainwright & Sutler's at tier two, out of the Clydesdale's stock,
its printed cooldown gone (no price for a Suppress by Ryan's rule of 17 October), its Suppress
landing only on a foe carrying Flak (Ryan, 22 October: the maker's condition, and no back-rank
clause), the maker's own status laid and cashed inside a round since Flak halves at the
round's end, the mirror of the Burning gate; its blow low on purpose (Claude's fill 1 to 3 at
heat 2), since the target carries Flak and every stack tops the blow up. The engine items are
one condition on a weapon's keyword, a rule that consumes a status for a point a stack with a
threshold, and the die showing both (section 7); the stuns left are the locked ones (the
funnel-web's web, the Baboon's Paradox, the Swallowtail's charged Flare), each gated as its
row says, and Aphelion keeps no slottable stun. Decided (Ryan, 22 October): the Ram Frame and
the Rangefinder are
mirrors, each a reach read, the Frame +1 on Direct blows aimed at the front rank and the
Rangefinder +1 on Indirect blows aimed at the back, the Frame's armour line gone and both
stat lines from the pricing run after the landing (the bible's catalogue row).

## 4. The foes

HP is the foes' word. Breach is a move's rider, so the first fill names the move; the Waste
keeps the most, one mid foe in each other domain by fantasy, the heroes whose weapons say so,
and the bosses mostly not, so the seal keeps its job against the big single blows.


| Foe | Domain | Today: HP, blow, armour | First fill | Breach and the big moves |
|---|---|---|---|---|
| Goblin | meadow | 30, 5, 0 | 3, 1, 0 |  |
| Dire Wolf | meadow | 30, 10, 0 | 4, 2, 0 |  |
| Gel | meadow | 40, 10, 0 | 5, 2, 0 | Engulf breaches: acid through everything (new); its halves 2 and 1 |
| Half-Gel | meadow | 20, 5, 0 | 2, 1, 0 |  |
| Mandragora | meadow | 30, 10, 0 | 4, 2, 0 |  |
| Treant | meadow | 140, 30, 5 | 32, 5, 1 | Root Storm at a third: 2 on every machine |
| Needler | waste | 20, 10, 0 | 2, 2, 0 | Needles breach, as today |
| Antlion | waste | 50, 20, 0 | 6, 4, 0 |  |
| Cockatrice | waste | 30, 10, 0 | 4, 2, 0 |  |
| Sandworm | waste | 160, 40, 5 | 36, 6, 2 | Swallow breaches, as today; Quake a quarter: 2 on every machine |
| Revenant | marsh | 30, 5, 0 | 3, 1, 0 |  |
| Ghost | marsh | 30, 10, 0 | 4, 2, 0 |  |
| Zombie Knight | marsh | 50, 20, 5 | 8, 4, 1 | Cleaver breaches (new): the Marsh's plate-killer, armour 1 of its own |
| Bone Wyvern | marsh | 140, 30, 5 | 32, 5, 1 | Bone Storm at a third: 2 on every machine |
| Bomb | peak | 30, 30, 0 | 4, 5, 0 | Self-Destruct breaches, as today; Flare Up a third: 2, scorch |
| Salamander | peak | 50, 20, 0 | 6, 3, 0 |  |
| Drake | peak | 30, 20, 0 | 4, 3, 0 |  |
| Magma Golem | peak | 160, 40, 5 | 40, 6, 2 | Slag Fist breaches, as today |
| The Warrior | meadow | 120, 30, 0 | 24, 5, 0 | Cleave below half breaches (new), its finisher |
| The Martial Artist | meadow | 100, 20, 0 | 20, 4, 0 |  |
| The Thief | waste | 90, 20, 0 | 18, 4, 0 | Mug corrupts, as today |
| The Lancer | waste | 110, 30, 0 | 22, 5, 0 | Jump and Dragon Dive breach, as today: the Dive 8 |
| The Cleric | marsh | 90, 10, 0 | 18, 2, 0 | Holy ×3: 6 |
| The Augur | marsh | 90, 15, 0 | 18, 3, 0 | Omen ×2: 6 |
| The Black Mage | peak | 90, 20, 0 | 18, 4, 0 | Flare below half breaches, as today: 8 |
| The Summoner | peak | 80, 10, 0 | 16, 2, 0 |  |
| the promoted forms | the finale | their heroes' kits, massive, armour 5 | HP The Warrior 48, The Martial Artist 40, The Thief 36, The Lancer 44, The Cleric 36, The Augur 36, The Black Mage 36, The Summoner 32, armour 2, their heroes' blows | the one move more each (section 12's slate) |
| the bosses (the slate) | each domain | not in content | HP 80 to 100, blows 6 to 10, armour 1 or 2 | mostly no breach, so the seal keeps its job; the Fallen Weapon's axe the exception by fantasy |

## 5. The modules

A standing point of armour walls a blow size for the whole game, so armour lines are scarce:
two modules keep one, +1 each, paid in move or in tier. Numbers at the new scale.


| Module | Maker | Tier | Today | First fill | Note |
|---|---|---|---|---|---|
| Ablative Plating | Minerva | 1 | hull +30, armour +5 | hull +8, armour +1, move −10 | the one tier-one armour line, paid in move |
| Ram Frame | Minerva | 2 | hull +60, armour +10 | a hull line from the pricing run; +1 on Direct blows aimed at the front rank | no armour line: a standing point is the dear one; the Rangefinder's mirror (Ryan, 22 October) |
| Spall Liner | Minerva | 2 | move -10, heat -20; [{"trigger": "on_hull_damage", "effect": "add_shield", "value": 10}] | move −10, heat max −4; +2 shield on hull damage |  |
| Boundary-layer Bleed | Kestrel | 1 | cooling +5; [{"trigger": "on_heat_gain", "effect": "add_shield", "value": 5}] | cooling +1; +1 shield on heat gain |  |
| Muzzle Velocity Booster | Kestrel | 2 | ; [{"trigger": "on_attack", "effect": "add_ceiling", "value": 5}] | ceiling +1 |  |
| Thrust Overboost | Kestrel | 3 | move +20, shield +30; [{"trigger": "on_attack", "effect": "multiply_heat", "value": 2}] | move +20, shield +12; heat ×2 |  |
| Flak Skirt | Wainwright & Sutler | 1 | hull +10, armour +5 | hull +6 | its armour line goes; a skirt is hull |
| Field Radiators | Wainwright & Sutler | 1 | heat +20, cooling +5 | heat max +4, cooling +1 |  |
| Tactical Databank | Wainwright & Sutler | 2 | ; [{"trigger": "on_attack", "effect": "add_floor", "value": 5}] | floor +1 |  |
| Artillery Rangefinder | Wainwright & Sutler | 2 | ; [{"trigger": "static", "effect": "spares_splash", "value": 1}] | +1 on Indirect blows aimed at the back rank | the Ram Frame's mirror (Ryan, 22 October); a planned draft until the reach read lands |
| Phase Conjugator | Aphelion | 2 | shield +10; [{"trigger": "on_shield_granted", "effect": "stack_status", "value": "braced", "stacks": 3}] | shield +4; Armoured 1 on an ally it shields | 3 today |
| Susceptibility Tensor | Aphelion | 1 | shield +10; [{"trigger": "on_attack", "effect": "add_damage", "value": 5, "when": "target_status"}] | shield +4; +1 against a foe carrying a debuff |  |
| Exotic-matter Shell | Aphelion | 3 | shield +40, heat +30; [{"trigger": "static", "effect": "add_damage_taken", "value": 10}] | shield +16, heat max +6; takes 2 more a blow | 10 today |
| Ward Plate | the Arsenal | 2 | shield +20, armour +5 | shield +8, armour +1 | the tier-two armour line |
| Grievance Reliquary | the Arsenal | 2 | hull +10; [{"trigger": "on_hull_damage", "effect": "stack_status", "value": "overcharged"}] | hull +4; Overcharged 1 a hull hit | the feed the halving clock bounds (section 12) |
| Tithe Coupling | the Arsenal | 3 | hull +50, shield +30; [{"trigger": "static", "effect": "hull_per_spend", "value": 10}] | hull +20, shield +12; 3 hull a spend |  |
| Trim Tabs (new) | Kestrel | 2 | | one free reroll of its own die a round; heat max −4 (or shield −4) | the Kestrel line's reroll module, priced so no module is the universal pick |

## 6. The engine spec (the first implementation chunk; no marks needed)

Each item names its home. Content numbers stay at today's scale in this chunk; the fills land
in the second.

1. **Tags.** The working set as the validator's list (`sim/content_db.gd`), lowercase ids
   (`ballistic` is in the engine already: the Cottonmouth's drum adds it); the filing tags
   retired once their readers are found (`melee` is read by the screen's lunge,
   `game/skirmish/skirmish_screen.gd`, and keeps its name; check `tools/balance.gd`'s class
   tally, the hangar page and the harness picker for the rest). A `tag_<tag>` condition keeps
   working (`sim/effects.gd`).
2. **Tiers stored.** Every non-fixed component carries `tier` 0 to 3; `ContentDB.component_tier`
   reads it; the three validator checks that today refuse a stored tier on a stocked piece
   invert (lines 1186 to 1216); the capital's maker has no tier zero where it had no tier one;
   `starting_blueprints` returns tier zero. A migration writes today's derived tiers into the
   content as stored values, so nothing changes in play. The stock-below-tier check is
   written but held behind a flag until the content landing re-stocks the chassis, since
   today's stocks violate it everywhere. Tests: `test_a_components_tier_follows_the_lowest_chassis_that_stocks_it`
   flips; the synthetic components in `tests/test_content.gd` that carry `tier` stay valid;
   `fins_pack` (line 721) gains one. Built 22 October, one step past this plan: the migration
   wrote today's tier one as zero and every other stocked piece a tier below the lowest chassis
   that stocks it (the unstocked pieces kept their stored tier), so today's stocks already
   stock below their tier and the check runs now, no flag needed; the landing's re-tiering
   must keep it.
3. **Danger close out.** The splash block in `Skirmish` (`DANGER_CLOSE_DIVISOR`, lines 1579 to
   1587), `Effects.spares_splash` and the Rangefinder's `spares_splash` effect (its module keeps
   its stats, its rule open), the reach tally's splash column and the report's "Splash a front
   spend" (`tools/balance.gd`), the bot's splash weight, the Cottonmouth's note, the rules'
   Indirect line and the vocabulary's entry. Spread and Penetrate on the explosives are content.
4. **One breach.** The blow walk (`Skirmish.blows_on` and `_damage_mech`) skips the armour step
   on a breach, both sides (our Breach keyword on a weapon face, `Face.Keyword`, the die's chip);
   the forecast, the foes' aim weighting (hull reachable) and the bot's damage-taken estimates
   read it; the Ward turns it away already; the vocabulary's Breach entry rewritten; the rules'
   not-built marks off. Tests on both sides.
5. **HP wording.** The codex, the plaque and the forecasts say HP of a foe (`game/`); the
   balance report's "Hull a spend" and like wording (`tools/balance.gd`); `sim/` log lines; the
   vocabulary gains an HP entry beside Hull.
6. **Rounds to win.** A figure per cell beside the win rate, random and greedy, mean rounds of
   the fights won (`pol.rounds` exists), as its own section of the report; the coordination gap
   is read as greedy against random on the big foes and the formations.
7. **Converters as fields.** `per_heat` on `shield_per_heat` and on the Afterburner's face
   (`power_per_heat`), the Puffin's `shield_per_ally_heat` with a `per_heat`; the engine's
   constants of the table above moved where they can be content, kept where they are code, at
   today's values until the landing. Built 22 October: the three steps are fields, written
   into the content at 10 (the landing sets the brief's 2, 4 and 2); Kindled and Siphoning
   already carried their content's number; the engine-wide rules (`CRYO_COOL_PER_STACK`,
   `HOT_HEAT`, `VOLATILE_BITE`, `MISSING_STEP`, Burning's and Scorched's heat, Vitriol's
   share) are a keyword's or a status's rule, so they stay named constants in code for the
   landing to re-set, as do the bot's absolute weights.
8. **The Spillover star.** The Boar's granted Spillover shown as the star, the printed-rule
   chip, in place of a keyword chip on every entry (`game/ui/die_face_view.gd`, `glyphs.gd`);
   the hold reads the passive's line.
9. **Field guides.** `content/chassis.json`'s `_about` still describes the whole-block shield
   and the derived tier; `content/components.json`'s `_about` the derived tier. Both rewritten.
10. **The baseline run** before any of this lands: `tools/balance.gd --seeds 200` on today's
    main into `docs/balance.md` (about 45 minutes, split with `--part i/n` and `--merge`), the
    heat section's first publication and the before for every band read later; the campaign
    report rerun with it. Done 22 October on main's head of that morning (`a1585a9`; the heat
    section had first been published on 21 October), with the coordination gap read today on
    the team rows beside it (`docs/measurements.md`).

## 7. The method (the second chunk, on Ryan's marks)

Ryan's marks of 22 October are structural (the calls below and in the tables); the numbers
are set by measured loops, never marked one by one (Ryan, agreeing with the direction run's
read: the first fills were the old numbers divided unevenly, `docs/measurements.md`).

1. **The engine first.** A rung that plans two rounds, so the coordination gap can be read
   (the greedy rung sets up only where the setup pays within the round; the bible pinned a
   rollout rung; built 22 October: the planner rolls out the greedy's best few spends at each
   decision over the rest of the turn, the enemy's turn and the next round on copies of the
   fight, and a blind rung plays the tests' blind team, each die on the nearest foe; the gap
   reads blind over the planner on the big fights and on the rank and file, the planner at
   about four greedy fights a fight, so on the team rows); the seven constants still in code as fields on their keyword or status
   (Cryo's cooling, the hot threshold, Volatile's and Corrupted's bites, Missing HP's step,
   Burning's and Scorched's heat on a machine, Vitriol's share; built 22 October: Volatile a
   numbered keyword whose bite each entry says, the missing-HP step the entry's `per_missing`,
   the hot threshold the move's `hot` beside `machine_hot`, Cryo's cooling and Corrupted's bite
   their statuses' numbers in the engine's table, where Burning's, Scorched's and Vitriol's
   already were, each at today's value; the applier sets the fields); the Breach keyword on the
   Railgun; the Ram Frame's and the Rangefinder's reach reads (built 22 October: Breach on the
   Railgun in content; the rank condition reads a reach beside it on an attack's own effects,
   and the two modules carry their rules, the Frame's armour line gone); a condition on a weapon's
   keyword for the Battery (the face names when its Suppress lands, a foe carrying Flak, read
   through the effects' conditions; the bot values it only where it holds and the die over a
   foe shows the chip struck where it does not); the Backdraft's rule (a printed rule, the
   star: the blow consumes every stack of a status the face names on the foe it hits, adds a
   point a stack consumed before the multiplies, and Suppresses at the threshold it prints; the
   die over a Burning foe shows the number with the stacks in and the chip lit only at the
   threshold; the bot weighs the ticks it gives up against the blow and the stun; built 22
   October: the face's gates and its consumes, the Battery's gate written `{"suppress":
   {"when": "target_status", "status": "flakked"}}` and the Backdraft's `{"suppress": {"when":
   "target_status", "status": "burning", "stacks": 2}}` beside `"consumes": "burning"`). The
   Inducer's Volatile needs nothing new: any component may carry it.
2. **The loop**, on the landed content (step 3 brought before it, 22 October: the applier
   fills numbers on today's stocks, and the gap is read on the new stocks' setups).
   `tools/stock_fills.py` applies a fill set to a checkout; the balance runner
   at 30 seeds reads it against section 2's tests (rounds to win on the rank and file and the
   massive foes, the gap, hull lost, the heat section), the campaign report the wear. Start
   from the brief's fills with the levers moved: the foes' blows up by half to double (the
   rank and file 2 to 3, the elites 6 to 8, the bosses 8 to 12) or our hull and shield down a
   quarter; cooling 0 on most chassis with the typical gun at 2 to 4, or maxima of 10 to 14;
   the massive elites' armour 1; the Treant's and the Wyvern's regrow 3; Flak's clock, a stack
   a round against the halving, read on the Flak team's massive-foe cells (section 12's
   question, Ryan's of 22 October). Move one lever a
   loop, read the bands, keep what passes; the module stat lines wait for the pricing run.
   Run 22 October (`docs/measurements.md`, six loops): kept the foes' blows up by half on the
   rank and file, a third on the massive foes and double on the heroes, the Sandworm's and the
   Golem's armour 1, the regrows 3, and the maxima 16 to 12 and 20 to 14 (the Kite's 10 and
   the Musk Ox's 8 standing); our hull and shield down a quarter and cooling 0 were read beside
   them and set aside; Flak's clock read alike under both on today's feeds and stays halving.
   The kill time on the massive foes (3 to 8 rounds) and the gap (1.0 to 1.2) stand where they
   were: Ryan's reads, with the bands (the bible's section 12). The review of the same evening
   (Ryan's go) raised the four light machines' hull from 16 to the scales row's floor of 20
   (the Prairie Dog, the Dingo, the Puffin, the Cottonmouth; the Kite's paper hull 12 stands),
   confirmed by a 30-seed loop (`docs/measurements.md`), and widened the row to the fills'
   field recharge (4 to 8) and the Condenser's capstone vent; `tools/stock_loop.py` is the
   loop driver, in the repository since.
3. **The content landing.** The stocks, the renames and retirements, the new pieces, the
   tags and tiers, the stock-below-tier check kept green; the rules' numbers and not-built
   marks; the bible's stock-pass row to built, its tables regenerated
   (`python3 tools/pages/bible_tables.py`), the vocabulary exported
   (`tools/export_vocabulary.gd`), the hangar page republished; the Stingray's and the
   Baboon's models rebuilt with their stock, or that line left to the asset session. Landed
   22 October, before the loops (step 2's note): the stocks, renames, retirements, new pieces,
   tiers and tags of sections 2, 3 and 5 as written; the Stoker's own fire a face field
   (`self_burn`, the one engine piece the stock needed); the numbers at the fills through the
   applier, in place; the shown text and the status descriptions at the landed numbers (the
   engine's descriptions read their own numbers since, `{value}`); the tests that copied a
   content or status number now read it. Not done: the explosives' area keywords (the tables
   give no shell both; Open for Ryan, 3), the three locked pieces the tables did not tag, the
   hangar's republish (with the loops' numbers, once) and the two models (the asset session).
4. **Read the bands fresh** at 200 seeds beside the baseline (`docs/balance.md` as the
   branch left it): walls and free wins as bands, rounds to win and hull lost on the rank and
   file, the gap on the big foes; every run a decision cites in `docs/measurements.md`.
   Run 22 October (`docs/measurements.md`; `docs/balance.md` and `docs/campaign_run.md`
   regenerated): the loops' reads hold at 200 seeds. The rank and file in under two rounds,
   the formations' wear and decision bands, heat on the hot kits; not met, the massive foes'
   2.9 to 7.8 rounds, the gap's 1.05 to 1.17, the teams' free wins on 19 to 28 of 29 packs,
   the finale's wall and the campaign's 1% of battles: the bible's section 12.
5. **Then** prices and tier ladders (the to-do's engine line) and Ryan's play for feel.

## 8. The chunks and the switch

Planning was this model's (21 and 22 October): the decisions are rows, the fills and the
spec are here. The implementation runs on Opus, in Ryan's words, so nothing below needs a
design call:

- **Chunk one**: section 6, built 22 October on `claude/eager-newton-sf947u` (main merged in
  first), the baseline reports run on main's head in a worktree beside it; items 2 and 7 say
  where the build went past this plan, and the Boar's row lost its stale "Breach is the foes'
  word" on the way.
- **The marks** (Ryan, 22 October): made, in the tables and section 3; two of his own
  suggestions in discussion (the Inducer's maker and price, a Suppress piece's lowest tier).
- **Chunk two, on Opus**: section 7 in order, the engine items first, each a commit with
  tests green, every loop's run in `docs/measurements.md`.
- **Back up** for the reads that are judgment: what the bands say, prices and tier ladders.

## Open for Ryan

1. The Backdraft Charge's threshold and numbers (Claude's fills: two stacks, a point a stack,
   base 2, heat 2) and the Battery's (1 to 3, heat 2): his to move before the loops, or left to
   them.
2. The content name pass, later (the working names: Canopy, Bleed Valve, Decoherence Veil,
   Airburst Shell, Flak Cannon, the Stoker; the Backdraft Charge's name stands; the printed
   rule's Burns its firer).
3. Which explosives carry Spread and Penetrate, and whether the basic kit wants a flat
   Indirect gun: both in the bible's section 12 since the landing (22 October).

## What the session hands back

On Ryan's marks: the content landing (section 7), the bible's stock-pass row to built and the
section 12 content questions closed, the rules' numbers and marks, the vocabulary, the
to-do's lines ticked, the status; this brief retires to git.

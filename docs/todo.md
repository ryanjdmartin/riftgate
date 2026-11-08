# To-do

One line per task: the specific thing to do, and what unblocks it when something does.
Grouped by who moves it. Tick a line when it lands, in the same commit as the work; the next
session prunes ticked lines (git keeps them: the last unpruned list is `git show
1fa1155:docs/todo.md`). A task lives here; a question only Ryan can answer lives in the bible's
section 12; the order of work is `docs/status.md`. Never the same item in two files. A judge
line names its debug switch or pose; `README.md`'s Running section says how each is run.

## Ryan

Calls and marks:

- [x] The skirmish code audit's eleven questions (`docs/skirmish_audit.md`, 7 November): answered 8 November and built, the mine's three left for the Lammergeier's rework
- [x] The audit's four questions still open (`docs/skirmish_audit.md`): answered 8 November and built

- [ ] Rules for the Muzzle Velocity Booster and the Tactical Databank (planned since 2 November: rolled damage is gone, so a ceiling and a floor move nothing)
- [ ] Mark the first rounds on your chassis ideas of 4 November (each now a brief in `docs/briefs/`, the roster the briefs README's "Ten a maker"; correct them in the hangar's Designs tab, a session folds those in first): the ten a maker's open calls first (whether the Wild Boar or the mole comes down to tier one beside the lure tank, the two moves to the Arsenal and the merges you have not marked; the roster under Design sessions), then the lure tank's armour with section 12's floor of 1, Static's cascade and triangle, the Macross's shift and its grants; then each brief's open list as its session comes
- [ ] Mark the session's placeholders in your content pass (31 October): the bosses' escorts at tiers two and three (`docs/bosses_proposal.md`; the read of 2 November: three of them walls), the Ruby Colossus's kit and name, the Djinn's slant in the ranks, Gilgamesh at 40 HP and his one-in-three chance, the massive lines' six recolours and the Marsh's three giants
- [ ] The Cinder Tortoise at tier three (flagged 2 November, left for now; Withdraw is 2 meanwhile): armour 3 and 5 withdrawn against blows of 2 to 6; read it with a tier-matched kit on `--boss-tiers` before anything moves
- [ ] The elites session's calls still yours (3 and 4 November): the elites' numbers (the first read: every cell a free win, the lone elites dead in two rounds; the massive band, an escort each, or the curveball on the map: section 12); the Emperor Scorpion's name (the King Scorpion straight is the other); the Thunder Ape's spin and cannonball dive, benched by the three-move budget; the Gargantuan King's name from your "<adjective> King" pattern; every new kit's name and numbers
- [ ] The rank-and-file bench from the elites session (3 November, your word: what misses the cut may be rank and file): Cerberus, the Whisker Cat (the Coeurl), the Sphinx, the Banshee, the Iron Giant, the Dullahan, the Roc, the Drowned King, Anzû; the Mother Bomb out (a suicide boss); the Coven and the gate gargoyles on your "not yet" of 15 October
- [ ] Settle the Backdraft Charge's threshold and numbers (your direction, 22 October: a point a stack of Burning consumed and the Suppress at a threshold; Claude's fills two stacks, base 2, heat 2) and the Battery's (1 to 3, heat 2); Flak's clock, reopened for Flak alone (section 12)
- [ ] Text: a codex for every chassis but the Honey Badger, the Clydesdale, the Kite and the Baboon, and a flavour for all but the first three; the components without a codex; each maker's Sponsorship notice in its voice; the mitigation discussion for the bible
- [ ] The content name pass (22 October: "go with your name suggestions, I'll do a content name pass later"): the stock pass's working names (the Canopy, the Bleed Valve, the Decoherence Veil, the Airburst Shell, the Flak Cannon, the Stoker), the Susceptibility Tensor, the Oblation Mantle in place, Ore Hopper and Ore Plate, Magpie
- [ ] A piece that pays in shield (the shield cost is built, locking the entry while the shield is short): which component carries it, and at what number
- [ ] The Bomb: whether it plays as more than an annoyance, judged in play (held, 4 November: not decided yet; the change on the table if it does not is a burst that also hits the foes beside it)
- [ ] The Null Field Emitter at Purge 2 (logged 3 November): a placeholder for Purge N on the one player piece that purges, to price once Purge N and the Numbed clock have been played
- [ ] Capacitor pieces that grant Charged and Supercooled (logged 3 November: no piece grants either primer yet): ideas proposed in chat first (a capacitor that charges on a vent, a coolant loop that supercools on a shield), then your notes, then content
- [ ] The Needletail's two modes and the Giant Petrel as the catamaran, your next session with less context (27 October): the Needletail in fast, mark, hover and vector to dodge, out fast (the wings that fold to hover, or the tail-sitter, `docs/looks/kestrel_needletail4.png`); the Giant Petrel's hull from `docs/looks/kestrel_giant3.png` (the navy surface-effect catamaran with Kestrel's flair, or the racing catamaran built Kestrel's from the start)
- [ ] Godot 4.8 stable once it ships: the desk's editor and templates, the cloud's fetch (the session-start hook), and the version in README, CLAUDE.md and the phone scripts

Judge (a deliberate test, with its switch):

- [ ] Judge the pacing session's pieces running on the phone (30 October, first cuts; `RIFTGATE_PEAK_DEBUG=1` peaks Rift Pressure every enemy turn): the tears opening on the seam and sending patrols, the seam's creep, the Rupture meter's bar under the gate's with a notch a Fracture, SEALED on the boss, a pack's members on a hold; then a battle for the clocks: whether a fought battle meets one or two tears (the timer's 12 is the old clock's number, Claude's lean 8 to 6), whether a pusher striking from anywhere along the wall reads as fair, whether the Rupture lands before the gate does
- [ ] Judge the four tilesets whole on the phone (`RIFTGATE_BLEED_DEBUG=1` paints the whole field, `RIFTGATE_FACTION=meadow|waste|marsh|peak`): whether each reads as its domain and its water and walls stand apart from its ground, and whether a battle's start hitches while the map is painted
- [ ] Judge the die's standard face on the phone (`tools/die_sheet.gd`'s sheet draws every kind): whether Exposed's open reticle still reads apart from the sight, whether the small marks (a readout's head, the chamber wheel, the passive box) read plain, the costs along the foot clear of the frame (`DieFaceView.MAIN_W` 60, `NUMBER_SIZE` 28, `AIM_Y` 86, `COST_Y` 111), and the three targeting modes' marks (Every Foe's bracketed formation, Every Ally's and Every Other Ally's arch, Sweep's lobbed line with its four rising strikes)
- [ ] Judge the round preview's return chips on the phone (7 November, first cuts): the rising arrow for a foe that gets back up and the fork for one that splits, in the skull's place, under a die that kills an Undying foe or a Gel; with them a Sweep's wasted shot landing on its empty slot (`RIFTGATE_MISS_DEBUG=1`: the jolt and the ring of dust) and a killed foe standing until the spend's last blow
- [ ] Play a Splash or a Penetrate shot at a massive foe (Ryan, 7 November: "Whatever it does now is fine, it will just be something to test"): today it takes the blow once, its own column adding nothing, and the foes beside it take the area's number
- [ ] Judge the keywords in text against KEYWORD INK (a debug build's SETTINGS): every term bold in its colour with its icon, or in ink with the icon alone coloured; the blue and red words' legibility (3.4 and 3.0:1 at worst)
- [ ] Judge the dice's gestures' timings on the phone: the double-tap window (0.2 s, `DieFaceView.DOUBLE_TAP_SECONDS`) against a tap that should open the readout, and the hold (0.45 s, `HOLD_SECONDS`) against a slow start to a drag, which locks instead
- [ ] Judge the colours on the phone, in a debug build's Settings → COLOURS (send its COPY text): the enemy's violet #c8a4ff against heat #ff4000 and harm #ff0000 (the `foeheat` pose), the GREEN preset's minty #60ffb0, whether the rings still part from the routes by structure alone; and the ladder's recolours each beside its base (`RIFTGATE_FOES=goblin,goblin_guard,goblin_captain`): a pair you cannot tell apart takes a lightness step in `tools/recolour.py`'s table
- [ ] Measure MSAA on the Pixel (Godot 4.8): a battle and a skirmish for ten minutes at the default MSAA 4X; if the game dies or slows, SETTINGS → AA MODE takes it down (tell me which held); your read of the look in each. With it the weld (a debug build's WELD, on by default: flip it and nothing on screen should change; the frame rate and heat each way), the intent field in motion, and the grid at `GRID_GAIN_PHONE`
- [ ] Judge the halos running with `RIFTGATE_HALO=off` and `=all` beside the vetted set (31 October), and whether the Musk Ox's forge mouths and back-blasts and the Cassowary's cells should wear one
- [ ] Judge the hit round and the shot trails running (`RIFTGATE_HIT_DEBUG=1` lands a blow every second and a half; SHOT TRAILS in a debug build's Settings, `RIFTGATE_SHOTS=1`; `RIFTGATE_PLUME=off` for the ring): the jolt's size, the flash's heat, the shield's ripple, the gutter; whether the shot crossing the field is kept, tuned or dropped; whether the Stingray's plume goes to the other boosters
- [ ] Judge the micro-models running (the hangar's Models tab, Fire; `tools/act_shot.gd`'s `fire:<component>`): the Swallowtail's flares and the Musk Ox's rockets, shell and casing, their size, speed, height, colour and timing; whether more pieces want one (the Giant Petrel's Spindrift Salvo, the Funnel-web's Web Bomb); and the render margin: a piece fired out is cut at the edge of its machine's view, so widen the margin or keep everything inside it
- [ ] The Wainwright & Sutler models' open calls (the hangar's Models tab): the Cassowary's cells blue or the maker's amber; the Cottonmouth's drum faster or slower at idle (say which before it changes); the Musk Ox's cells white or gold and whether they should track its ammo (offered: five a side, one ejected as a round is spent)
- [ ] Hear the remaining halves on the pair page (map halves for The Crossing, Full Bore and The Far Bank; Low Ground's battle half)
- [ ] Hear the pair page's later rounds (3 November): Night Shift's tenth (the whole battle half on the driven bass, the synth bass or a slap bass; R a sixteen-bar jam; the map half without its muted guitar); The Far Bank's map half's fourth (the strings section's and the climax's cuts with each lead on single notes, the strings section's 3 dB down); and on Hold The Line's settled pair whether the drone held level into Z is what "don't increase the volume of the choral drone in Z" meant
- [ ] Hear the in-game sound on the phone and confirm or overturn the calls made landing it (a hovercraft steps like a flyer, information lines wait only for the line in progress and a second, no route tick, random pitch only on footfalls and plates); then a full play of Hold The Line, notes by section letter

## Design sessions

Each runs from its brief in `docs/briefs/`, one session each, proposed in chat first; the
briefs' README gives the shared context and what each waits on; the order of work is the
status's.

### The roster: ten a maker

Ryan, 4 November: "I want to target 10 per maker, at least for now." The roster is the briefs README's "Ten a maker" as his calls left it, each design in its brief; the moves and merges he has not marked stand as its plan. Three slots are open (the Magpie's or another Kestrel design, Aphelion's tenth, the Arsenal's tenth), 47 named.

**Kestrel**, ten: eight decided.

- [ ] The Magpie (a working name), Kestrel's support engine (`kestrel_magpie.md`; the first round: the thief, the mimic, the cache; its cache beside the time-shifter's bank), its tier open, the slot open to another design
- [ ] The Lammergeier's rework, Ryan's (8 November: "Flag the mine path as an issue but don't bother fixing mine problems until the rework, in case it stops existing"): the mine path's known faults wait for it (`docs/skirmish_audit.md`: Bug 7, Questions 9 and 11, the mine's half of Root 1 and of Structures 4 and 7)
- [ ] The Snowy Owl, Kestrel's stealth unit (`kestrel_owl.md`; the first round: cold is quiet, the hunter on the map, Hidden as a status), leaning to Cryo (Ryan, 5 November: "assuming we take the cryo direction with the owl - which makes a lot of sense"); stealth a new rule (Phased cannot act, so it is not stealth)

**Wainwright & Sutler**, ten, all named.

- [ ] The kits and visual designs of five machines, a design session each, Ryan's to start (4 November: "All 5 need a design session to complete their kits and their visual designs. I'll start that up myself"): the Musk Ox (and whether a shield reloads it at all, Ryan, 8 November: "that's a question for its design session"), the Whip Scorpion (its rework, tabled 3 November; its blast's random pick is the one draw of the player's turn besides the die; his shapes on the table: a vent, or an ally's vent, giving a temporary buff, the Siphon's heat-on-hit moved to its passive, one strike to the blast per vent in the turn), the Swallowtail (its Reveille Horn replaced entirely, Ryan, 8 November: "The thing to change is the horn entirely, since a horn is kind of silly, but that can wait"; its Rallied and its log's word go with it, so "rally" stays the foes' move), the Needletail, and the gunship (`ws_gunship.md`, "very rough right now and might need to go back to the drawing board"; Claude's first round of 3 November in its brief); their runner reads of 3 November are not his concern until then

**Minerva**, ten: the Honey Badger, the Armadillo and the Wild Boar built.

- [ ] Minerva's replacement tier-one tank or tanks, Ryan's own design (4 November): the lure tank (`minerva_lure_tank.md`: "Every hit lures", each hit taken an Armoured until the round's end; its base armour and section 12's floor of 1, what counts as a hit, the bot's lure valuation), or the Wild Boar or the mole come down ("either Boar or Mole will move down"); the Armadillo moves to tier two as it lands (the bible's Armadillo row and section 12's question)
- [ ] The echidna (the hedgehog) and its Sonic Needle, with the Retribution Thurible's change (`minerva_hedgehog.md`), left open (Ryan, 20 October); his new shape of 4 November (strikers debuffed to hurt themselves after they act) and Claude's first round in the brief
- [ ] The Cryo party defence (`minerva_cryo_defence.md`; Ryan, 4 November: "units with Cryo deal 1 less damage or something", laid by a party-wide trigger): the trigger first (Claude's lean, a blow on any ally's shield, which parts it from the echidna)
- [ ] The immune one (`minerva_immune.md`; Ryan, 4 November: immune to every buff and debuff, passed to an ally by a component and taken back, the receiver's statuses cleared): whose statuses, breach, who keeps it when its machine is wrecked
- [ ] The drill-tank mole (`minerva_mole.md`; Ryan, 4 November: it "needs a better hook than 'ignores armour' but we can work on that later"): its verb, then whether it or the Wild Boar comes down
- [ ] The siege battery, Ryan's H-tank (`minerva_siege_battery.md`), parked on his charge brief of 20 October until he picks it up
- [ ] The battlecruiser, Minerva's capital ship (`minerva_battlecruiser.md`), never with the Carrier's session (Ryan, 20 October)
- [ ] The shield bash, a potential Minerva tier-three weapon or module (`minerva_shield_bash.md`; Ryan, 4 November: "bonus damage equal to armour, then armour zero until end of round"; Claude's lean the weapon): its form and numbers, then content as planned

**Aphelion**, nine named and one open: the Stingray and the Baboon built.

- [ ] The Baboon to tier two (`aphelion_baboon.md`; the stock pass left it at tier one), waiting on Ryan; its move waits on another Aphelion tier one landing (the line frame, Static or the Barrier and Ward support)
- [ ] The line frame, the Gundam homage (`aphelion_line_frame.md`), waiting on Ryan
- [ ] Static, a tier one and Aphelion's shock unit (`aphelion_static.md`; Ryan, 4 November: every weapon or equipment hit lays Static 1, a damaged Static foe hurting itself and the foes round it a point a stack, Static conducting Chain): the cascade, the triangle on strikes, guns and armour
- [ ] Aphelion's defensive tier one, the Barrier and Ward support (`aphelion_barrier_ward.md`; Ryan, 19 October: to balance the tier-one bodies beside Minerva's and Kestrel's off-tank; 4 November: "Barrier+Ward support. Have to make it interesting but not broken"): its three shapes, Claude's lean the Barrier half; in Aphelion's session its Shock and Chain setters (a Spread Shock debuff the arc's natural partner, Ryan's lean of 28 October) and its Cryo setter
- [ ] The jellyfish, the soft-control specialist (`aphelion_jellyfish.md`), waiting on Ryan; its Disrupt read again after the foes' fresh start; the status detonator folded in, unrefined (Ryan, 4 November), its shape and holes in the brief
- [ ] The time-shifter, kept unrefined (`aphelion_time_shifter.md`; Ryan, 17 October: "delaying and redirecting blows"; 4 November: "an entire unexplored area"): the delay, the bank, stasis; Aphelion's open tenth is the time area's if it wants it
- [ ] The Carrier (`aphelion_carrier.md`), on its own, waiting on Ryan
- [ ] The Macross, Aphelion's flagship at tier three (`aphelion_macross.md`; Ryan, 4 November: three modes, each colouring its attacks and granting allies a buff as it shifts), the aura-shifter folded in: what shifts it, Battroid's Armoured on every ally (the form the Swallowtail's row refused), the bible's transforming chassis pin reopened

**The Arsenal**, nine, its tenth waiting until its many unrefined ideas are settled (Ryan, 4 November): the Nemesis and the Ammit built.

- [ ] Misharu with Penance (`arsenal_misharu.md`), waiting on Ryan
- [ ] The Onryō's curse, its kind open again since Flak (`arsenal_onryo.md`; Grudge was a working term), waiting on Ryan
- [ ] Mastema, fire through the team, with the Scapegoat Brand's fate (`arsenal_mastema.md`), waiting on Ryan
- [ ] Minos (`arsenal_minos.md`), waiting on Ryan
- [ ] The Zoids walker, the Arsenal's on the ten-a-maker plan (`zoids_walker.md`; Ryan, 12 October: "The kill-turning-rapid as a feline/canine hunter mauling feels very Arsenal"), its verb open again (its first was the Kite's Reset)
- [ ] The frost figure, the Cryo detonator moved from Aphelion (`arsenal_frost.md`; Ryan, 4 November: "Plants cryo and somehow blows the cryo for damage, adding Suppress if enough stacks consumed"): the one to check for room with the Snowy Owl on Cryo too; if the Owl takes the detonator whole, the Arsenal has two slots open
- [ ] The thunder figure, the shock unit's Arsenal half (`arsenal_thunder.md`; Ryan, 4 November: "Arsenal is some kind of thunder demon/god homage"): Claude's lean, Chain's capstone at tier three, never another punisher of the striker beside the Onryō and Misharu

**Every maker**

- [ ] The bible's records of the plan, at the Armadillo's move or the next records pass, republished by the Pages procedure: Minerva's, Aphelion's and the Arsenal's next-chassis rows (section 7) for the ten a maker, the jellyfish's fold in Aphelion's row, Aphelion's row's pointer for the time-shifter (its own brief since 5 November), and the transforming chassis pin if the Macross is taken

### The other design sessions

- [ ] The component pass (Ryan, 4 November: the roster's unsupported archetypes and holes, a fifth basic gun, Indirect, among them; the pool's size by its holes, not a count, about 50 to 75 blueprints his lean), not before more is settled; every piece proposed in chat first
- [ ] The roster's synergy holes from the map (`docs/synergy_map.md`), each a piece proposed in chat first: fire's second payoff beyond the Backdraft's stun (a reader that does not consume); a slottable Cryo setter (tier one, Indirect, no damage, Cryo 2 on the foe a hot ally will hit next; Aphelion's by Ryan's lean), which also closes the ally-heat hole; Purge as the first counter every setup status shares; a slottable Expose piece, Kestrel's lean ("Kestrel holds Exposed")
- [ ] The heat session (`docs/briefs/heat_pillar.md`; Ryan, 28 October: heat is a core pillar and undervalued; the bible's triangle row and section 12's heat question): every component carries a price in heat, hull or shield, so the twelve free slottable pieces get theirs; passive cooling as the lever (0 by default, a chassis's cooling its identity where it keeps one); vent payoffs; the overheat's price first since the read of 30 October (caution costs more than the overheat: a harsher burn, burnout through the injury rule, self-Corrupted, his call by feel; `--overheat N`, `--burnout`, `--overheat-corrupt N`); then the vanilla ladder's heat grid again on the chosen levers before any price lands
- [ ] The heroes beyond Final Fantasy (Ryan, 15 and 16 October: balance the series out a little, never purge it): proposed in `docs/heroes_proposal.md` and the conversions section of `docs/bosses_proposal.md`; Ryan's marks, then content, art and rows
- [ ] The economy pass, a session of its own (`docs/economy_pass.md`): the runner's spending policy first, then every price and yield with the offers one of each kind, a chassis on the shelf, the Favour dock as the gate's price, twelve to sixteen battles; the items the roster analysis's go left for it (the host maker's offer, the boss's token, the shelf, what Salvage and Favour buy); a won final's extra pay (Ryan, 26 October) read against the beaten domain's reprieve

## Engine

- [ ] The skirmish code audit's fixes in its order (`docs/skirmish_audit.md`; its bugs built 8 November but the bot's readings and the die-in-hand forecast, which go with their steps): one hit routine with its arguments in place of the hidden flags, the mine's half left for the rework; one round model; the bot's and the screen's mirrors onto the engine's helpers, then a 30-seed direction; statuses as data, the Face, the dead code and the comments

- [ ] The test runner reads a test that crashes after its first check as passed (`tests/run_tests.gd` fails only a test with no checks; found 30 October): a way to count a crash as a failure (a sentinel each test sets last, or the log scanned by a wrapper)
- [x] A Purge on a Sweep weapon: settled by the spend's order (Ryan, 7 November), every hit's riders before the death check and what a kill brings back after the spend, so a Purge on the killing hit keeps an Undying foe down; built 7 November
- [ ] Read the Skua with the next matrix, alone and beside the Puffin with the Overcharge Coil (its base halved, its buffs whole on each hit, 7 November); Ryan's levers if it proves weak: "Each weapon or equipment fires twice, instead. This would let stacks apply to the second fire", or "Instead of halving, reducing by a flat amount"
- [ ] The Cottonmouth's drum on every weapon it fires (the weapon-fire work is on main since 4 November): its hidden mounts fire with a shot of the ranging act's shape that turns two chambers forward (Ryan, 3 November: "Shots moving two makes sense"), a slice of its own built with the hookup, and no per-gun effect at a hidden pin (Ryan, 2 November: "I'd rather suppress them to avoid any clipping or effects bleed through the drum"); the hangar's motion script holds it since 3 November (`Stage.hidden`)
- [ ] The armed aim reworked or retired: it reads the entry a machine shows, a transient property (Ryan, 26 October: "this makes no sense"); the Thief carries it, left until then
- [ ] The aims' shown words rewritten plainly for the foes that carry one, once the aims are tuned (Ryan, 21 October: "aims at the exposed" is cryptic): five proposals in the retired interceptor brief's seventh round (`git show 9ced5e5:docs/briefs/kestrel_interceptor.md`), then `AIM_TEXT` in `sim/foe.gd`, the vocabulary's Aim entry and `docs/vocabulary.md`
- [ ] A silence carrier once Ryan marks it (the shaman; section 12) and a boss's purge on his marks (the Djinn carries the ranks' since 2 November), and the front's card warning of a purge among the leaders, with the mission map
- [ ] The 200-seed matrix on the desk machine, in parts (the README's `--part` and `--merge`), into `docs/balance.md`: the formations by tier and a cell for every recolour (the ladder), the compositions' cells (patrols, formations, elites by domain and tier, the boss with its escort; `--packs elites`), the two Petrels' rows, the flattened numbers of the randomness pass, read as bands beside their 30-seed directions in `docs/measurements.md`, numbers moving only on Ryan's word; with it the injury threshold's what-if (Ryan, 3 November: "Flag injury threshold for another session to analyze next time it runs the 200"), since injuries break the entry showing now
- [ ] Test the Ammit's Quintessence Tap at single digits (Ryan, 28 October: "might be too strong with the reduction to numbers"; 8 November: "each empowered stack is worth way more than when it was originally designed. Needs a unique form of testing"): its Empowered carries from fight to fight, so a battle's chain of fights, not one fight, against a purging pack once one exists; whether the Tap should still protect its stacks from a Purge is the bible's section 12
- [ ] The campaign runner's player: Ryan's large change, a session of his after the audit (4 November); the lone-fight read waits on it
- [ ] The module catalogue as soft-synergy pairs on the tags (the Ram Frame and the Rangefinder the reach pair, the Booster and the Databank the roll pair; no module reads a tag yet; the slottable carriers by tag in `docs/synergy_map.md`): Claude's bench, two readers a tag (Beam reads Burning, Arc reads Shocked or lays Flak, Ballistic reads Flak, Plasma reads hull damage); every per-blow amp converges on the strike pieces and the area pieces, a convergence to watch
- [ ] The heat report's next reads: a `--heat` recipe that fields one chassis three ways (tuned to its cooling, hot with vents, mixed), the cautious and the reckless persona side by side (`--cool-above N` built 30 October), the hot rows next; forced choices that spent a vent or a cooler weapon instead
- [ ] The bot reading a swap for the acting order (its bunching built 22 October); Minos's rank turn on the foe-moving engine
- [ ] The Lammergeier's stock, proposed in chat: the stock pass's table had no row for it, so it still carries its stand-ins by kind of 21 October (the Incendiary Shells, the Enfilade Beam, the Polarity Projector, the Arc Fault Cannon)
- [ ] The greedy bot's valuation of support (`shield_score` counts the hull saved this round, not the blow turned next round; `Policy.shield_ahead` is the persona that does, `--shield-ahead`; a status laid for an ally and a second action on the map count for nothing), before the runner is asked about any support frame; the pricing pass's rung: a persona that shields and vents before the overheat and the planner beside the greedy on the equipment ladders (no shield or vent is spent by the greedy on any bench); with it the Differentiation Probe, the Entropy Condenser and the Ammit's loop are read before their numbers move; and the greedy rerolls only as a round opens, so a reroll a spend brings mid-round is a look it never takes (the Petrels' pieces read it by the bank, `Policy.bank_delta`; the Reveille Horn's Rallied still as a look)
- [ ] The domains' engine gaps: a foe-side interpose (the Warrior's Cover) and retaliate (the Martial Artist's Counter, the Salamander's Ember Hide), a rare pack that flees on the map (the Gold Bug), the Mimic as loot, placement and the bleed by domain
- [ ] The promoted forms' one move more for six of them and Fáfnir's mechanics, once Ryan marks the slate (`docs/heroes_proposal.md`, section 12); then the reserve behind the finale's line
- [ ] The map mechanics the elites' fantasies ask for beyond what they carry today (an aura or a field effect; the blitz is the World Eater's push at speed, the swarm the Shuffler's and the Leshy's) and the battle bot answering them, once Ryan marks the kits; the Thunder Ape to carry enemy Shock when section 12 settles it
- [ ] Prices and tier ladders (Ryan, 11 and 12 October: a component is balanced against its tier's others, never by a chassis's solo win rate; 28 October: tiers two and three "need to feel worth it to upgrade to", plain number increases beside the keywords, "especially to shield and vent"; the bible's effectiveness and pricing rows, section 11; the runs in `docs/measurements.md`, 27 to 30 October). Next: the equipment ramp Ryan wants first, read where support has work (the ladder's tier-two and tier-three formations with tier-matched kits, the planner beside the greedy; the support ladders on the Puffin bench read flat), the shields' and vents' numbers by tier as a fills proposal for his go; the ladders per tier on the fresh start's formations and recolours; the area pieces on the formation cells alone; the Meteor's Splash 1 at Burn 2 as the next what-if if Ryan wants a Splash on it; the Phase Conjugator read on the Puffin bench; the crossing's price (each chassis that crosses water or crags read by solo and team value against a ground twin)
- [ ] The hangar's economy verbs on the run (the host maker's offer, a token unpacked, building from a blueprint, fitting a module), procurement (each standing maker's stock for Favour, refreshed each turn; the Arsenal's trickle at the capital) and loot on the map, after the economy pass
- [ ] Onboarding: the gesture tutorial and the cheat sheet, the reroll rule and the round first

## Map and screens

- [ ] A prototype hangar in the game, no economy: paints on every machine and a refit's look before a battle (`Unit.paint`, `RIFTGATE_PAINT`)
- [ ] The mission map (the capital centred, four cities, each front a card of words: domain, guest, ground, tier, its boss (the domain's hero once its final is set), how long its gate holds; a fallen city's horde marching on the centre, its rift drawn as art and never selectable; the capital's gate the one bar; the party card, `Campaign.party`) and the hangar (the shop, the roster, the host maker's offer)
- [ ] The draft screen: the tender, take three (`Campaign.tender`, `Campaign.new(seed, team)`)
- [ ] A wreck stays on its hex and blocks it for the battle (Ryan, 4 November; today it leaves): the engine and the bot walking round it, its death on the map; corruption in a pack's wake, once decided

## Art

- [ ] Art waiting on a route for the image model (foeforge's `generate` and `fix` ran on the Mac): renders for every boss, elite, part and giant wearing a placeholder (`tools/placeholder_art.py`); the heroes' costumes redrawn for variety (`HERO_STYLE` in `tools/foeforge/forge.py` dresses them all alike: a prompt of its own each); the promoted forms' boss-register art (each wears its hero's chibi until then); a summon's moment on the skirmish screen
- [ ] The Augur's next art pass (Ryan, 26 October: "she's still not correct"): what is still wrong is his to say before the round, which waits on a route for the image model; her surviving renders are under `tools/foeforge/out/` (`augur_heroart9`, `augur_chibi_heroart9`, `augur_heroart16`, `augur_chibi_heroart16`)
- [ ] Aphelion's thrusters as a model brief, how they look (the bible's makers table: thrusters and space-age rockets rather than rotors)
- [ ] New foe types from the candidates Ryan marked, once he decides them (section 12)
- [ ] The hangar as a model; a licensed icon set (game-icons.net, CC BY) in place of the line-drawn glyphs, in one pass

## Audio

- [ ] The pairs in the game, once the halves are picked (Hold The Line's settled 3 November): each pair one synchronized stream, the map choosing the track and looping it about twice before the next, a fight flipping to its battle half in place over 3 s from ENGAGE and back on the field, the boss's reveal as today; each picked half into the forge's SHIP table at its level
- [ ] Level the other five tracks against Hold The Line through the phone model
- [ ] Boss themes for the Meadow, the Waste, the Peak and the finale, melodies proposed in chat first
- [ ] Foe tags (Ryan, 4 November: flavour the codex shows, hooks for audio and perhaps attack and death animations, never a mechanic; the bible's foe tags row, section 9): the working set proposed in chat first (his examples: Undead, skeletal; Animal, demonic; flying), then `tags` on every foe in content with the validator holding the set, the codex showing them beside the name, and Jenny's foe-down pools (undead, demonic, eldritch) keyed by them
- [ ] A foe death per domain, later
- Stretch, not now: a burn or shock modification adds its own sound layer

## Pages (standing)

- Republish the bible from the committed file to its one URL (in status) after every bible change
- Republish the hangar page with `tools/hangar_data.py`'s map after every content, model or render change
- After Ryan edits on the hangar's Content tab: pull `edits` with ArtifactData, apply by hand, test, commit, republish, clear the documents
- Re-seed the Melody Desk's `parts` after a track's voices change (`desk_parts.py`)

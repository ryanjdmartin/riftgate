# Wainwright & Sutler: six new chassis

A pitch, 11 October 2026, from Ryan's candidate silhouettes: two true spider tanks (four
legs, and more than four), a digitigrade biped (the AT-ST), a medium combat helicopter, a
large multi-rotor or helicarrier homage, and a fan-boat hovercraft. Nothing here is decided.
Names, designations, numbers, kit and model briefs are Claude's fills for Ryan to replace
against his own notes before anything lands in `content/`. The holes in the brief are in
section 3, the order I would build in is section 4.

## 1. Where Wainwright & Sutler stands

- The maker row (bible section 7): wheels and quads, perhaps a helicopter, no bipeds;
  old-West iron, indirect fire, area, suppression; field notes; the frontier's working
  animals and pests. Designations are "Pattern N" and a job; parts look bolted on and
  squared off; the metal is matte iron and warm brown; a machine dies winding down.
- Three chassis: the Clydesdale (tier 2, assault walker, the big die and its free reroll),
  the Prairie Dog and the Dingo (tier 1, light cars whose map rules are their passives).
- What the runner shows (`docs/balance.md`, 9 October): the W&S team is the weakest maker
  row, and both W&S tier ones are light cars that cannot hold a fight alone, so the tender's
  W&S offer is always a fragile one.
- Propulsion reads the maker (2 October): Kestrel flies on boosters, Aphelion on fans set
  flush, and the exposed-rotor fan-copter is kept for a later Aphelion flyer; W&S flyers are
  traditional helicopter profiles. The helicopter style of movement is in the engine, pinned
  and unused (bible section 7, motion).

## 2. The six

| | Silhouette | Size, tier, way | The idea | Passive | Engine |
|---|---|---|---|---|---|
| **Spadefoot** | Spider, four legs | Medium, 1, walker | The battery that digs in | Fighting without having moved, every weapon gains Spread | A `planted` condition |
| **Harvestman** | Spider, eight legs | Heavy, 2, walker | Climbs where walkers cannot, nets a rank | Crags are slow ground to it, not walls | Crags priced by passive |
| **Emu** | Chicken walker | Medium, 1, walker | Kicks through the fodder | A spend that kills is Rapid | Rapid on a kill |
| **Horsefly** | Medium gunship | Medium, 2, flyer | Sees over the line | Every weapon is Indirect | Runs today |
| **Longhorn** | Twin-rotor lifter | Assault, 3, flyer | The flying battery | Indirect weapons strike twice | A strike added |
| **Skeeter** | Fan-boat hovercraft | Light, 1, hover | The decoy | Every hunter takes it as prey | The mirror of never hunted |

Numbers are in the content's tens and are placeholders. Stock uses today's components only;
the stock pass will move it.

### 2.1 Spadefoot (Pattern 6 Battery Walker): the four-legged spider

- **Silhouette.** A true spider tank on four legs: a low, wide casemate slung between four
  long legs whose knees rise well above the deck, each leg ending in a broad spade foot, a
  gun's trail spade set edge down. The homage: the four-legged spider tank of Ghost in the
  Shell (1995), crossed with a towed howitzer's trail spades.
- **The idea.** The battery that digs in. It is strongest where it stands, so it is placed a
  turn ahead of the horde, on the walk the map already shows, and fights what comes to it.
- **Passive: Trail Spades.** "When the Spadefoot fights without having moved this turn, every
  weapon it fires gains Spread." One idea, and it multiplies whatever is fitted (any weapon
  becomes a rank-wide one); the price is on the map, where a turn spent walking is a turn
  without it. A hunter that catches it finds it planted (a caught machine cannot move first),
  and so does a fight an ally opens within its range. The hunters that pick the slowest
  machine (the Wolf, the Antlion, the Thief) often walk into its spades. Engine:
  `grant_keyword` `cleave` exists and honours a `when`; the `planted` condition (no move spent
  this turn, UNDO MOVE restoring it) is new, read from the battle's `move_left`. The die shows
  Spread on every weapon while it holds, as a granted keyword already does.
- **Fixed.** None: the design is the passive over generic kit, as the Clydesdale's is.
- **Numbers.** Medium, tier 1, walker, move 30; hull 110, shield 40, armour 5, heat 60,
  cooling 5, field recharge 20; 5 hardpoints (d5), 2 module slots.
- **Stock.** Howitzer, Ankle Mortar, Incendiary Shells, Twin Autoguns, Laminar Deflector.
  Stocking the Howitzer on a tier one makes it a tier-one blueprint (derived), one more at a
  run's start.
- **Model.** A flat riveted casemate, chamfered, wider than long, its belly a hand off the
  ground; a squat turret on the deck carries hp_1 forward (the Howitzer); hp_2 to hp_5 on the
  deck's four corners, squared pads in the maker's brown. Each leg leaves a corner at a hip,
  climbs to a knee above the turret's roof and drops near plumb to its spade. From above the
  hull is a slab framed by four knees: the knees are the silhouette. Joints: hip (yaw and
  pitch), knee and ankle on every leg; the turret's yaw; the gun's elevation.
- **Acts.** Digs in (the legs splay, the hull settles onto its belly, the spades bite, then it
  rises); traverses the turret out and back; lifts a foreleg and stamps the spade in; tests
  the gun's elevation. **Under way:** a spider's diagonal walk, hull level and low, knees
  lifting high.
- **Planted, on the map.** Shown by pose, not by hue: the hull down on its belly while it has
  not moved, so the state reads in structure.
- **Names.** Spadefoot, the lead: the spadefoot toad of the American West digs itself in
  backwards with spades on its hind feet, so the name, the feet and the passive are one
  picture, and a toad's name does not miscount the legs. Tick: the cattle tick of the Texas
  trails, low, flat, dug in and not letting go.

### 2.2 Harvestman (Pattern 2 Siege Walker): the eight-legged spider

- **Silhouette.** The Wild Wild West homage, Loveless's iron tarantula in W&S iron: a riveted
  cab forward with eight amber lamps for eyes, an abdomen behind carrying the Spinneret
  Mortar and a short stack, eight long legs arching high over a body slung low. "Tarantula"
  is a BattleTech 'Mech (`content/reserved_names.json`), so the homage needs another name.
- **The idea.** The spider that goes where walkers cannot, and nets what it finds. Crags are
  a wall to every ground machine; to the Harvestman they are a perch.
- **Passive: Grapnel Feet.** "Crags are slow ground to the Harvestman, not walls." A map rule,
  as the cars' passives are: it climbs onto a crag (the step ends its move) and down the far
  side next turn, so it is the one ground machine that crosses a ridge. Badlands (crags 20%
  of the field) is the flyer's map; this gives it a ground answer. Engine: a static effect
  read where a way of moving prices a hex (`BattleMap.move_cost` takes traits today and needs
  the unit, or a derived trait), by the drawn reach and by the bot's paths.
- **Fixed: Spinneret Mortar** (new). Indirect, flat 5, Suppress and Spread, heat 20, shape
  rack. A cable net thrown over a rank: three foes suppressed for one spend. The Suppression
  Battery hits one foe harder; this one is wider and deals almost nothing.
- **Numbers.** Heavy, tier 2, walker, move 30; hull 140, shield 30, armour 10, heat 80,
  cooling 5, field recharge 15; 1 fixed and 4 hardpoints (d5), 2 module slots.
- **Stock.** Maxigun, Howitzer, Blast Door, Coolant Jacket.
- **Model.** Two bodies: the cab, a riveted dome with a visor band and eight lamps in two
  rows, and a larger abdomen behind, iron plates and a brown band, the Spinneret's tube rising
  out of its tail with the stack beside it. Eight legs from the cab's rim, each a hip, a knee
  well above the dome and a long shin to a small foot, the front pair longest. hp_1 to hp_4 on
  the cab's shoulders and the abdomen's flanks. From above: two ovals and eight legs
  radiating, a spider at any size. Joints: hip (yaw and pitch), knee and ankle on all eight;
  the Spinneret's elevation. The leg span is wide for a heavy: the legs overflow the hex as an
  assault machine does, or the class fit shrinks the body; settled at the first render.
- **Acts.** Rears onto its hind six with the front legs raised (the threat); test-fires the
  Spinneret (the tube lifts, glows, settles); lowers its body to the ground and rises; turns in
  place on its legs. **Under way:** an alternating gait, four feet down at a time, the body
  gliding level.
- **Names.** Harvestman, the lead: the daddy longlegs is exactly the posture asked for, legs
  arched high over a body carried low, and a harvestman is also a farm hand, a working animal
  by pun. Recluse: the brown recluse, a barn pest of the American South, brown as the livery,
  and it sits back. Redback: the Australian widow, the shed pest beside the Dingo; also
  Hanwha's Redback, the Australian Army's infantry fighting vehicle, the homage tier the Dingo
  already sits in.
- **Alternative passive.** Long legs that step over: it may cross, never stop on, a crag or
  another unit's hex. More spider, more engine (paths through occupied hexes).

### 2.3 Emu (Pattern 5 Patrol Walker): the chicken walker

- **Silhouette.** The AT-ST, with a nod to RoboCop's ED-209: a squared riveted cab on two
  long digitigrade legs, no arms, twin guns under the chin, a launcher on the cab's flank,
  spurs on the heels.
- **The idea.** The fodder-kicker. Every kill frees it to go again, so it wades through a
  front rank of small things.
- **Passive: Overrun Clutch.** "A spend of the Emu's that kills is Rapid." Rapid exists: the
  entry switches off for the round, the die rerolls free, and the machine acts again; so at
  most one spend per entry a round, never a loop. It pays any weapon that finishes foes, and
  the die showing the exact number makes the kill a plan (a flat 15 on a foe with 15 left).
  Engine: the resolver's Rapid check also fires when the spend killed (a static
  `rapid_on_kill`).
- **Fixed: Rowel Spurs** (new). Direct, flat 15, heat 5, the melee tag; the cowboy's spur
  wheel on each heel, a kick. Flat is the finisher, which is what the clutch wants.
- **Numbers.** Medium, tier 1, walker, move 40 (the fastest walker; no machine of another way
  loses to it on every ground, so the content check stays quiet); hull 90, shield 40, armour
  5, heat 60, cooling 5, field recharge 20; 1 fixed and 3 hardpoints (d4), 2 module slots.
- **Stock.** Twin Autoguns (the chin guns), Ankle Mortar (the AT-ST's side launcher, and an
  ankle mortar on a bird's leg), Laminar Deflector.
- **Model.** A box cab with a visor slit under a brow and a chamfered chin, a hatch in its
  brown roof; hp_1 the chin guns, hp_2 on the left flank (the launcher), hp_3 on the right.
  The legs: a hip under the cab, a short thigh forward to a knee, a long shin raking back to a
  high ankle, a long foot forward onto three toes, the rowel a spiked wheel behind each heel.
  The cab turns on the hips, the AT-ST's head turn (the second cockpit that turns, after the
  Clydesdale's head). Joints: hips, knees, ankles, toes; the cab's yaw; the rowels spin.
- **Acts.** Looks round (the cab sweeps, pauses, sweeps back); scratches the ground with a
  foot, the rowel spinning; bobs (the cab dips and comes up, a bird's nod); a test kick, one
  leg lashing forward. **Under way:** a bird's walk, the cab nodding onto each foot.
- **Names.** Emu, the lead: a frontier pest, and in 1932 the bird that saw off an army
  machine-gun detachment in Western Australia; W&S naming a war machine after the side that
  won is the field notes' kind of joke, there for Ryan's codex if he wants it. Cassowary:
  Queensland's kicker, whose casque could be the cab's sensor crest.
- **Alternative passive.** Every weapon Chains (runs today), but a chain repeats itself with
  no decision, where Rapid hands the player a fresh roll and a choice.

### 2.4 Horsefly (Pattern 14 Escort Gunship): the medium helicopter

- **Silhouette.** The Mi-24 Hind in W&S iron: a narrow armoured fuselage, two stepped bubble
  canopies (a horsefly's eyes), stub wings with two mounts each, a chin turret, a five-blade
  main rotor and a tail rotor. The traditional profile the 2 October note kept for W&S flyers.
- **The idea.** The gun that sees over the line: every weapon it carries reaches the back
  rank, and it pays for shooting the front.
- **Passive: Look-down Sights.** "Every weapon the Horsefly fires is Indirect: it reaches any
  foe, and splashes at the front rank." Direct hits harder for its heat (reach is priced), so
  a Horsefly fitted with Direct guns hits the healers and casters behind the front at Direct's
  numbers, and shooting the front costs it shield. The Artillery Rangefinder (a W&S module,
  tier 2) cancels the splash: a module found in the run that changes the machine, never a
  piece it needs. It answers the Marsh (kill order and reach, the healer behind). Engine:
  runs today (`set_reach` `indirect`, static, already in the pipeline; no chassis uses it
  yet; equipment is untouched, since a shield's glyph and target follow its kind).
- **Fixed.** None.
- **Numbers.** Medium, tier 2, flyer, move 30 (the slow flyer: Kestrel's jets are 40 and 50);
  hull 100, shield 40, armour 5 (the Hind's "flying tank"), heat 60, cooling 5, field
  recharge 20; 5 hardpoints (d5), 2 module slots.
- **Stock.** Maxigun, Enfilade Beam, Twin Autoguns, Incendiary Shells, Laminar Deflector. The
  Maxigun's three strikes teach the splash fast.
- **Model.** A boxy, bolted fuselage; the canopies two glass bulges stepped one above the
  other; stub wings across the waist with hp_1 to hp_4 hung under them; hp_5 the chin turret;
  the rotor a hub and five blades on a mast, drawn as blades and never a disc so the hull reads
  through from above; a tail boom, a fin and a tail rotor. It floats (nothing touches z = 0).
  Joints: the main and tail rotors spinning (as the Stingray's fans do), the chin turret's yaw.
- **Acts.** A pedal turn (a quarter round in place, a hold, back); sweeps its chin turret;
  climbs and settles; sideslips out of its hex and back with a bank (map only). **Under way:**
  the pinned helicopter style: it keeps its facing and tilts into its travel (strafe and tilt
  in its cornering numbers), so the pin comes off.
- **Names.** Horsefly, the lead: the pest of horses and cattle, riding along with the
  Clydesdale. Gadfly. Mosquito.
- **Alternative passive.** Its Direct weapons gain Penetrate, a strafing run down the column.
  Runs today too and leaves the reach rules alone, but it would make the third W&S chassis
  whose passive grants a keyword.

### 2.5 Longhorn (Pattern 17 Battery Lifter): the large multi-rotor

- **Silhouette.** The Mil V-12, the biggest helicopter ever flown and the oddest design that
  worked: a long boxy fuselage under a braced high wing, a great rotor at each wingtip turning
  against the other, and along the top between them a flat deck with its landing square
  painted on, carrying the battery. The deck is the helicarrier's nod, done with W&S's
  traditional rotors (section 3 says why not the helicarrier itself). From above: two huge
  rotor discs left and right, the horns, and the deck between.
- **The idea.** The flying battery: W&S's tier three, the artillery capstone, indirect fire
  twice over.
- **Passive: Ripple Selector.** "Every Indirect weapon the Longhorn fires strikes twice." A
  strike is a separate blow that rolls and carries the keywords; heat is paid once a spend;
  each strike at the front rank splashes. It doubles any maker's indirect weapon (the
  Shotfire Rack, the Meteor Artillery and the Solar Flare Array as well as W&S's own), burns
  twice, and makes front-rank fire dear. A plain multiplier, the Sparrowhawk's kind. Engine:
  an on_attack `add_strikes` with `when` `reach_indirect` on the effective face, beside the
  raised ceiling and floor.
- **Fixed.** None.
- **Numbers.** Assault, tier 3, flyer, move 20; hull 170, shield 50, armour 5, heat 80,
  cooling 5, field recharge 15; 6 hardpoints (d6), 2 module slots.
- **Stock.** Howitzer, Suppression Battery, Incendiary Shells, Ankle Mortar, Blast Door,
  Coolant Jacket.
- **Model.** The fuselage a flying wagon, slab sides, rivets, brown; the wing on struts; a
  rotor head on a nacelle at each tip, the blades mirrored for opposite spin (`_lift_fan`'s
  `hand`); the deck plate on top with its markings; hp_1 to hp_6 on the deck in two rows of
  three, all of them reading from above; twin fins at the tail. It floats, and an assault
  machine overflows its hex. Joints: two rotors spinning opposite ways, the deck mounts' yaw.
- **Acts.** A battery drill (the deck mounts traverse in turn, left to right); a slow yaw and
  settle; a gust (a wingtip dips, the rotors fight it, it rights itself); the mounts elevate
  in sequence, a ripple. **Under way:** a heavy heft, a gentle tilt into its travel, barely a
  bank.
- **Names.** Longhorn, the lead: the Texas trail's cattle, the twin rotors spread like the
  horns. Ox. Bullock (the Australian bullock team).
- **Alternative passive, the helicarrier as a command deck.** "Allies' Indirect fire never
  splashes while the Longhorn is in the fight." The carrier directs fire from above; but it is
  an aura (new to the engine), and it empties the Artillery Rangefinder on any team fielding it.

### 2.6 Skeeter (Pattern 11 Picket Launch): the fan-boat hovercraft

- **Silhouette.** An airboat on a skirt: a flat, wide hull on a black skirt, one huge pusher
  propeller in a round cage at the stern (the airboat's, and the LCAC's), twin rudders behind
  it, a closed wheelhouse forward (no vehicle has an open cockpit, so the airboat's high seat
  becomes a caged cab), a long punt gun along the bow. From above: a rounded slab and a big
  circle at its tail, apart from Kestrel's boosters and Aphelion's flush fans.
- **The idea.** The decoy. The Prairie Dog is never hunted; the Skeeter is always hunted, and
  it is fast on the water no pack can enter. The cars' trade, a third way: never hunted, acts
  twice, draws every hunter.
- **Passive: Straight-pipe Manifold.** "Every hunter that appears takes the Skeeter as its
  prey. While it cannot reach the Skeeter, it walks for the gate." It pulls hunters off the
  team and drags them into a fight the team chose: a caught Skeeter's fight comes first, and
  every machine in range may join, a planted Spadefoot among them. The second line is the
  bound (section 3, the decoy): hiding the Skeeter out on a lake turns its hunters into
  pushers, so hiding costs gate. Light, so a careless decoy dies. Engine: a static
  `always_hunted` read by `Battlefield.pick_prey`, the mirror of never_hunted, and a hunter
  whose prey it cannot reach walking as a pusher.
- **Fixed: Fowling Cannon** (new). Direct, rolled 5 to 15, Spread, heat 10, shape barrel. The
  punt gun: a market hunter's shotgun the length of the boat, for a whole flock at once.
- **Numbers.** Light, tier 1, hover, move 50 (the fastest hover, ten water hexes); hull 60,
  shield 30, armour 0, heat 60, cooling 10 (the fan), field recharge 30; 1 fixed and 3
  hardpoints (d4), 2 module slots.
- **Stock.** Ankle Mortar, Incendiary Shells, Laminar Deflector.
- **Model.** A shallow iron tray of a hull, chamfered at the bow; the skirt a black band; the
  wheelhouse a squared box with a visor under a cage; the propeller a hub and long blades
  inside a ring cage on a frame; the rudders behind; the Fowling Cannon on a swivel at the
  bow, modelled in; hp_1 to hp_3 on the side decks. It floats over the skirt's line. Joints:
  the propeller spinning, the rudders' yaw with the steering, the bow gun's yaw.
- **Acts.** Revs (the propeller spins up, the hull squats and rocks); swings the punt gun
  across the bow and back; fishtails (rudders hard over, the stern kicks out and back); the
  hovercraft's balance (it tips in a gust, catches itself and settles with a heave).
  **Under way:** flat, no bank, the stern kicked out through corners as the Puffin's is, the
  rudders swinging.
- **Names.** Skeeter, the lead: the bayou's mosquito, whose whine an airboat's is; also the
  Saunders-Roe Skeeter, a fifties helicopter, the coincidence tier. Gator. Muskrat (the fur
  trade's swamp rodent, a pest that holes the levees).
- **Alternative passive.** The Spadefoot's mirror: having moved this turn, every weapon it
  fires gains Penetrate (a run-in down the column). The same engine piece as the planted
  condition, no hunter questions; it is on almost every time it attacks by order, and off
  when it is caught or joins where it stands.

## 3. The holes

1. **Nine of nineteen.** W&S would go from three chassis to nine while Aphelion and the
   Arsenal have two each. The tender is unaffected (one W&S tier one a tender, whatever the
   pool), but the host maker's offers, the hangar page and the runner's maker rows tilt, and
   six models is most of a week of lowforge rounds. Land three, keep three as drafts.
2. **No bipeds.** The maker row says so, and the reason it exists is identity by silhouette:
   Aphelion owns the humanoid frames, Minerva perhaps heavy bipeds, the Arsenal creepy walkers.
   A chicken walker has no arms and no torso; it reads as a gun cab on legs, a vehicle, as a
   quad does. So rather than an exception, the row could say "never a humanoid (no arms)",
   which keeps the reason and lets the Emu in. Two things beside it: the Ammit already walks
   on digitigrade legs (it reads as a creature, not a cab, so I think they stay apart); and
   the Clydesdale is "a horse on an AT-AT's legs", so an AT-ST makes W&S the house that builds
   the war films' walkers.
3. **"Perhaps a helicopter", and Minerva's flying brick.** The row says one; the 2 October
   propulsion note says W&S flyers, plural, so two sit within its spirit. But Minerva's row
   promises "one flying brick", and a big armoured multi-rotor at W&S would take it. Kept
   apart: Minerva's brick is armour (everything is a tank), the Longhorn an open frame with
   low armour and a deck of guns.
4. **The helicarrier itself.** Its fans are set into its deck, which is Aphelion's propulsion;
   its carrier verbs live elsewhere (airlift is a city ability, a drone screen a command-die
   idea); a rearming deck refilling allies who fought breaks "shield returns only in a turn out
   of a fight"; and its size wants more than one hex, the multi-hex boss's open engine
   question. Hence the V-12 carrying a deck: the nod in the silhouette, W&S's rotors, one hex.
5. **Map rules as passives.** The Harvestman's and the Skeeter's passives are map rules, as
   the Prairie Dog's and the Dingo's are. "A passive must open build space" was written
   against passives that feed their own fixed components, which a map rule does not; but four
   of nine W&S passives would then change the map. That could be the maker's identity on
   purpose (field craft: W&S machines change how the map plays), or a reason to move one of
   the two to a fight passive (each has one written as its alternative).
6. **The decoy.** Every hunter in today's content is a front-rank foe with ring 1, and most
   front-rank wildlife hunts (the Goblin, the Wolf, the Needler, the Antlion, the Revenant,
   the Bomb, and four of the heroes). Unbounded, "every hunter takes the Skeeter" lets a
   Skeeter two hexes out on a lake hold half the horde at the shore and free the team from
   every forced fight. Hence the second line: a hunter that cannot reach it walks for the
   gate. Whether that is bound enough is a runner question (the battle bot), before anyone
   trusts it; the Penetrate alternative has none of it.
7. **Spread three times.** The Spadefoot grants it; the Spinneret and the Fowling Cannon carry
   it. Area is W&S's word, so I think it is right; if it crowds, the Fowling Cannon loses it
   first and stays a plain rolled gun.
8. **Power at tier one.** Spread on every weapon is a big multiplier for a starter, and the
   Emu's clutch is strong against the Meadow. The knobs: the Spadefoot's to Indirect weapons
   only; the Emu's to once a round.
9. **Tiers.** The Spadefoot's Howitzer becomes a tier-one blueprint (derived). The Longhorn
   would be the game's second tier three, beside the Ammit; any maker may field one, but it
   says W&S is where the artillery capstone lives.
10. **Spiders on four legs.** A spider has eight; mecha's spider tank has four by convention
    (Ghost in the Shell, Halo's Scarab). A spider's name on four legs reads as a miscount,
    hence the toad.

## 4. The order I would build in

1. **Horsefly.** It runs today, it is W&S's long-promised helicopter, it takes the pinned
   helicopter movement off the shelf, and it answers the Marsh's back rank.
2. **Spadefoot.** The sturdy tier one W&S lacks in the tender, the most W&S idea of the six
   (artillery that digs in), and one small engine piece.
3. **Skeeter.** The cheapest model, W&S's hover, and the cars' trade completed; one small
   engine piece and a runner read on the decoy.

Then the Emu, once the maker row's wording is settled; the Harvestman (the eight-legged rig is
the biggest model job of the six); the Longhorn last (tier three, once the Horsefly has proved
the rotors).

## 5. What landing one takes

- Ryan's changes in chat, then the entries: `content/chassis.json` (and
  `content/components.json` for a new fixed component), `design.fantasy` and `design.niche`
  from this page, codex and flavour left for Ryan. A passive the engine cannot run yet lands
  as `"status": "planned"`.
- Its engine piece, tested with a synthetic passive (tests never assert on an entry's
  passive), and the vocabulary for any new term (the shown text above uses existing words
  only: Spread, Rapid, Indirect, slow, crags, hunter, prey).
- Its model: a function in `tools/lowforge/models_low.py`, its rig sidecar, four acts and its
  movement, judged on renders and running (`RIFTGATE_ACTS_DEBUG=1`, `RIFTGATE_MOVE_DEBUG=1`).
- The records: the bible's maker row (bipeds, if the Emu lands), the chassis table, the size
  classes, the motion table and the helicopter pin; `docs/rules.md`'s chassis count; the
  hangar page republished; the balance runner rerun.

# The Arsenal's new chassis

A pitch of 11 October 2026, on Ryan's call that day: more Arsenal chassis, "medieval, demonic,
eldritch, sinister", since the enemy's move to the JRPG domains left the demonic, occult and
eldritch register to the Council and the Arsenal alone. Everything below is a proposal: names,
numbers, kit and looks are Ryan's to move against his own notes before any of it lands in
`content/` or the bible, and the holes in section 3 are for discussion first (CLAUDE.md).

## 1. The frame

**The occult is ours now.** The naming line had two sides: Earth's animals for us, myth and
religion for the invasion, the Arsenal the deliberate exception. The domains moved the invasion
to the JRPG bestiary (the Gel, the Treant, the Bone Dragon), so the line has three sides now:
Earth's animals for the four city makers, the genre's high fantasy for the invasion, and the
occult, the demonic and the eldritch, for the Council and its house alone. The Arsenal is the
only place the player meets the dark, and every new Arsenal machine is where it shows.

**Held to the tone row.** Doom and Space Marine, over the top and played straight, never
grimdark. The demonic and the eldritch live in silhouette, posture, motion, glow and the
manual's liturgy: plate, black chrome and red glass, horns of steel, limbs too long or too many,
a stillness that is wrong. Never flesh, gore, organs or skulls, and never Evangelion: these are
serviced machines with pilots in them, and the creepiness is how the Council chose to build them.

**Named for what punishes.** Nemesis and Ammit set the through-line: a figure of myth who stands
for justice, vengeance or retribution, never war. The new register widens the bench, not the
rule: Hell's wardens, avenging spirits and angels of punishment all serve justice in their own
myths, so a player who looks a name up finds the Council's righteousness and Hell in the same
entry. Spread across cultures, since Egypt and Greece would swallow the list: Mesopotamia, the
Hebrew apocrypha, Dante, Japan. Two of the four are Ryan's own candidates from the old bible
(Misaru and Onryō, "next to look at").

**One for each word, one for each domain.** Each machine leads with one of the four words and
answers one domain's question, so each is the right pick somewhere and a slower fight elsewhere
(mismatch costs time, never ability).

| Word | Machine | Tier, size, moves | Its idea | Answers |
|---|---|---|---|---|
| Medieval | **Misaru**, the knight | 2, heavy, walker | Its shield raised is its arm strengthened | The Peak: shields for the telegraph |
| Demonic | **Mastema**, the gargoyle | 3, heavy, flyer | Fire passes from the dead to their neighbours | The Meadow: numbers that swarm |
| Eldritch | **Minos**, the hanged saint | 3, medium, hover | Its indirect blows drag the back rank forward | The Marsh: the healer behind |
| Sinister | **Onryō**, the crawler | 2, light, walker | Its allies' wounds are its strength | The Waste: damage no shield answers |

**Across the other makers' lines.** The Arsenal builds "bipedal-ish walkers first, some large
aircraft or hovercraft, always a little creepy; leg counts convert, legs ride on hoverjets,
aircraft carry arms". So: a walker (the knight), its first large aircraft (a gargoyle with arms),
its first hover (legs on hoverjets), and a walker whose arms and legs are the same limbs (the
crawler). With the Nemesis and the Ammit that makes six: three at tier two, three at tier three,
every size class but assault.

## 2. The four

Numbers are placeholders in the content's scale (player damage in fives; hull, shield and heat
in tens). Stock is drawn from today's pool and is provisional until the stock pass places the
basics. Codex and flavour are Ryan's.

### Misaru, Arsenal Instrument II (medieval)

- **Name.** Mīšaru, the Mesopotamian god of justice and equity: the most lawful name for the
  most lawful-looking machine. Alternates: **Víðarr**, the silent Norse avenger; **Zhong Kui**,
  the demon-queller of Tang legend, wronged in life and a hunter of ghosts after it. A hole:
  Misaru reads like Mizaru, the see-no-evil monkey, which is the kind of name Aphelion's
  primates take; Misharu, as the Akkadian is said, dodges it.
- **The look.** A gothic knight, too tall and too narrow at the waist: fluted plate in black
  chrome, red glass in the seams; a flat-topped great helm with a T-shaped visor slit lit red, a
  sensor head (the cockpit rides in the chest); long tassets and pointed sabatons (poulaines); a
  pavise as tall as its torso on the left forearm, ridged down the middle and carrying the
  Council's seal; a halberd taller than the machine in the right hand, its axe blade and spike
  edged in red glass. From above: the pavise a long slab on the left, the halberd's head forward
  on the right, the helm's crest between. Mounts: hp_1 the right pauldron, hp_2 the left shoulder
  behind the pavise's top edge, hp_3 a reliquary on the back.
- **Character: at vigil.** Still, upright, ceremonial. Acts: sets the pavise's foot on the
  ground and leans on it; raises the halberd in salute, its edge lighting; kneels on one knee
  and rises; turns the helm slowly, the slit brightening as it looks. Under way: a measured
  march, the pavise held before it, the halberd upright.
- **Passive: Accolade Relay** (the accolade is the blow that makes a knight). *Gaining shield
  Overcharges it.* `{"trigger": "on_shield_gain", "effect": "stack_status", "value":
  "overcharged"}`, which the engine runs today: a stack for the skirmish, fading a stack a round,
  and shield from any source fires it, an ally's too.
- **Fixed.** The **Vigil Pavise**: shield 30, self only, Overshield, so it always stands shield up
  and always feeds the relay; the only self overshield in the game. The **Interdict Halberd**:
  Direct, flat 10, heat 5, Penetrate (tags Blade, Melee): a polearm reaching through the front
  rank to the back of one column. An interdict is the Church's sentence; interdiction is fire
  behind the lines.
- **Stock, three hardpoints.** Oblation Ward, Proximity Klaxon, Plasma Arquebus: a second shield
  that bleeds it, a lure that brings the blows onto the pavise, a gun.
- **Numbers.** Hull 120, shield 40, move 20, heat 80, cooling 5, armour 10, field 20, two
  modules. A die of five.
- **Build space.** Every shield is a blow: shields on its own die (each one costs a weapon),
  allies who shield it (the Puffin's Backwash Ionizer passes the maximum; the Halo Shield; an
  Arsenal ally's Oblation Ward), modules that stand shield up (the Spall Liner on hull damage,
  the Boundary-layer Bleed on heat), and weapons that carry the stacks onto more than one blow
  (the halberd's Penetrate, the Maxigun's strikes). A full shield gains nothing and foes aim at
  exposed machines, so the knight wants to be struck: the lure is its other half.
- **Its cost.** Slow and short of reach; when nothing strikes it, only the pavise feeds it.
- **Answers the Peak.** It raises shield before the telegraphed blow and strikes harder for it.

### Mastema, Arsenal Instrument XI (demonic)

- **Name.** Mastema, the chief of the spirits in the Book of Jubilees, who asks to keep a tenth
  of them under him because great is the wickedness of men, and whose powers strike down
  Egypt's firstborn: God's own executioner with demons at his command, which is the Council in
  one name. Alternate: **Alastor**, the Greek avenging spirit that demonology made Hell's chief
  executioner.
- **The look.** A gargoyle off its cathedral, the Arsenal's first large aircraft: a hunched
  torso and a horned head with a long jaw; two broad vanes of black chrome panels like a bat's
  wings, ribbed in red glass, that tilt and vector and never flap; legs drawn up beneath in a
  gargoyle's crouch; two long arms carrying the Unction Cauldron before its chest, its mouth
  glowing, seen from above past the head. Boosters under the wing roots, each exhaust one glow,
  pale at the centre and deep red at the rim. The homage: the Stryge, Viollet-le-Duc's chimera
  on Notre-Dame. Mounts: hp_1 and hp_2 on the vanes' roots, hp_3 and hp_4 a pair on the
  shoulders.
- **Character: a gargoyle that has left its perch.** Acts: spreads its vanes wide and holds;
  tips the cauldron and its mouth flares with embers; hunches with the vanes folded round it,
  then opens; lifts the cauldron and peers down over its lip. Under way: heavy and wide,
  banking, the vanes vectoring, the cauldron swinging a little in its hands.
- **Passive: Brimstone Bellows.** *While it fights, a Burning foe that dies passes its Burning
  to the foes beside it.* Not built: one engine piece, a death handing its stacks to its
  neighbours in the rank (the passive carries `"status": "planned"` until then).
- **Fixed.** The **Unction Cauldron**: Indirect, flat 10, heat 15, Burn and Spread (tag Flame).
  Extreme unction is the last anointing; this one is poured burning from above, and seeds three
  foes at once. On the front rank it splashes as any indirect fire does, so pouring on the front
  costs it shield.
- **Stock, four hardpoints.** Meteor Artillery, Blazethrower, Incendiary Shells, Entropy
  Condenser: three burners and a vent.
- **Numbers.** Hull 120, shield 40, move 30 (the slowest flyer), heat 100, cooling 5, armour 0,
  field 20, two modules. A die of five.
- **Build space.** Every burn on the team spreads, not only its own: the Stingray's deepened
  stacks, the Aurora Lattice's Primed, the Solar Flare Array, the Incendiary Shells. Kill order
  is the decision: the burning foe in the middle of a rank is worth more dead than the one at
  its end. A Burning tick that kills spreads too, so a rank can catch during the enemy's turn.
- **Its cost.** Nothing to spread to against a lone boss; hot, unarmoured and slow for a flyer.
- **Answers the Meadow.** A crowded rank of goblins is fuel.
- **Why not "every blow burns".** It would run today (`on_attack` `add_burn`), but it is the
  Aurora Lattice's Primed made permanent, the kind of copy that pulled the Catalyzer Matrix, and
  the engine lands a passive's extra burn on the primary target only.

### Minos, Arsenal Instrument XIII (eldritch)

- **Name.** Minos as Dante drew him at the mouth of the second circle: the judge who hears each
  soul and sends it to its place by coiling his tail, which is what this machine does to the
  enemy's ranks. Alternates: **Gozu**, Ox-Head, the warden of Hell's gate who drags the dead
  before their judge; **Rashnu**, the Zoroastrian judge whose scales weigh the soul at the
  bridge.
- **The look.** A hanged saint, the Arsenal's first hover and its legs on hoverjets: a gaunt
  figure in a long robe of overlapping plates ending in a hem off the ground; below the hem two
  thin legs hang straight, feet pointed down, a hoverjet glowing red in each sole; arms long
  enough to reach the hem, the left hand open on long fingers, the right holding the chain of
  the Gibbet Hook; a narrow hood with no face and a ring of small red glass eyes round its
  crown. From above: the round hem, the ring of eyes, the long arms. Mounts: hp_1 and hp_2 a
  pair rising from the shoulders like a cowl, hp_3 and hp_4 a pair from the robe's front.
- **Character: a body on a gibbet.** It hangs and sways instead of balancing like a platform on
  water (a new hover idle). Acts: raises both arms slowly from its sides, palms out, and lowers
  them; casts the hook a little way out and reels it in, the chain swinging; sinks until its
  toes almost touch the ground and rises again; tilts its head too far to one side and holds it
  there. Under way: it drifts with its legs trailing behind it, never banking. On water it
  skims (a hover's water is fast), which is a codex line waiting for Ryan.
- **Passive: Penance Windlass.** *Its indirect blows drag: a back-rank foe struck trades places
  with the foe in front of it.* A foe the blow leaves standing steps forward; with nobody in
  front it steps into the empty slot; intents and targets go with the foes; a massive foe has
  no back rank to drag from. Not built: the swap in the skirmish, its forecast and drawing, the
  save, and the greedy bot learning to value it (the bot reads one spend's trade, and a drag
  pays on the team's next spends).
- **Fixed.** The **Gibbet Hook**: Indirect, flat 10, heat 5, no keyword. The drag is the point;
  Lure is the lever if it needs more, the hooked foe turning on the hover that hooked it.
- **Stock, four hardpoints.** Suppression Battery, Shotfire Rack, Plasma Arquebus, Entropy
  Condenser: drag and stun, drag and hit, a gun for what it dragged, a vent.
- **Numbers.** Hull 90, shield 40, move 30, heat 80, cooling 5, armour 0, field 25, two
  modules. A die of five.
- **Build space.** Every indirect weapon is a hook, and its rider decides what arrives: a
  suppressed healer, a burning caster, a disrupted Drake. The team's Direct weapons are the
  payoff, so it rewards ordering the round's spends. The foe sent back is out of Direct reach,
  which is a cost or a shelter.
- **Its cost.** Little damage of its own, and no area.
- **Answers the Marsh.** The White Mage and the Ghost are dragged into the front rank's fire.

### Onryō, Arsenal Instrument IX (sinister)

- **Name.** The onryō, the Japanese spirit that comes back to avenge a wrong. Alternate:
  **Hannya**, the Noh mask of a woman turned demon by jealousy and resentment. Spelling: the
  Rajdhani and Barlow faces carry ō and Share Tech Mono does not, so content may want Onryo.
- **The look.** Wrong in how it moves: a long thin body slung low between four long limbs, arms
  and legs alike, every joint bending the wrong way for a person; a smooth mask with two red
  slits for a sensor head (the cockpit rides in the body), under a fall of black cable hanging
  forward like hair; the Misericorde folded along the right forearm, katar-style. From above: an
  X of limbs, the cables spread over the front. A knowing homage to the crawling ghosts of
  Japanese horror, the shape and the move. Mounts: hp_1, hp_2 and hp_3 along the spine,
  pointing forward.
- **Character: still, then sudden.** Acts: freezes, then twitches its mask to one side and back;
  rears onto its hind limbs, holds, and drops; drags itself a step forward on its arms and back;
  unfolds the Misericorde and folds it away. Under way: an offbeat crawl, limbs out of step, a
  pause every few steps.
- **Passive: Martyrology Engine.** *An ally taking hull damage Overcharges it.* A martyrology is
  the Church's register of martyrs and their sufferings; this one keeps the team's. Not built:
  one trigger, an ally's hull damage, fired on every other machine in the fight (blows, bites
  and overheats count, as for every hull-damage passive; its own wounds never do, so nothing
  feeds itself).
- **Fixed.** The **Misericorde**: Direct, flat 10, heat 5, Rapid (tags Blade, Melee). The mercy
  dagger, for the stroke that ends a wounded knight: mercy on the face, the killing blow on
  reflection. Rapid gives it the turn back, so its stacks ride on two blows in a round.
- **Stock, three hardpoints.** Maxigun, Blazethrower, Laminar Deflector: three strikes for every
  stack to land on, a burner, a shield it badly needs.
- **Numbers.** Hull 70, shield 30, move 40, heat 60, cooling 5, armour 0, field 25, two modules.
  A die of four.
- **Build space.** The team is its kit. The Nemesis wants hull damage and makes it; an ally on
  the Tithe Coupling or carrying volatile kit pays hull on every spend; the Oblation Ward bleeds
  whoever raises it; a lure puts the blows on an ally that can afford the hull. Sinister on
  reflection: the Council's machine profits from CARE's wounds.
- **Its cost.** Light and fragile, and its passive is dead alone (the Puffin's case), so the
  runner's solo row will read it weak, by design. It can spike behind a swarm; one stack an ally
  a round is the cap if it does.
- **Answers the Waste.** The Needlers breach past shields to hull, and every breach is a stack.

## 3. Holes in the direction

1. **The tone.** Demonic and eldritch drift two ways the bible forbids: into grimdark (gore,
   skulls, cults) and into Evangelion (flesh in the armour). Section 1 holds them at plate and
   silhouette; worth stating in the bible's tone rows so every later Arsenal brief inherits it.
2. **How loud the Council is.** A demonic machine says something about the Council, and the
   lore keeps open, on purpose, whether it had a hand in the rifts. If the shown text names
   demons, the Council's nature becomes the premise instead of a reveal. Proposed: demonic in
   look and effect, liturgical in what the player reads. The manual never says demon; it says
   devotion, penance, judgement. The names keep the justice through-line, and Hell is what a
   player finds behind them.
3. **The names rule.** Section 1 keeps "something that punishes" and widens the bench. The
   alternative is any demon or eldritch being (Moloch, Baal, the sins), which loses the
   Council's self-image. The sins vein (Hubris) stays open beside it either way.
4. **The component names.** The bible asks whether "sanctified on the face" still governs the
   Arsenal's components, with hellfire on its word list. This direction answers no: they may be
   demonic on the face. These four still lean on the church and the gallows (Vigil, Interdict,
   Unction, Accolade, Penance, Martyrology, Misericorde, Gibbet) with one Brimstone, because the
   double meaning is the Arsenal's joke; the call is Ryan's.
5. **Ranks hold.** The bible decides that the enemy's ranks hold. Minos breaks it for one
   machine: moving foes becomes a player power. Editing the rules is the eldritch fantasy (the
   Chorus did it from the other side), but it is a decided line.
6. **A fifteenth keyword.** A new verb belongs on a component, so the drag could be a keyword
   (Drag) that Minos's passive grants its indirect weapons, which would also serve the Gravity
   Knuckles' open "pull a back-rank foe forward". The count already stands at fourteen against a
   recommended ten, so this pitch keeps the drag on Minos's passive alone; if it becomes a
   keyword, the Knuckles keep the other gravity option (half damage to the foes beside the
   target).
7. **Overcharged as the Arsenal's coin.** Two of the four mint it, beside the Grievance
   Reliquary, Devour and the Overcharge Coil. A family trait, or sameness? The Onryō's
   alternative is a vendetta: the foe that wounded an ally takes double from its next blow,
   which needs a new mark and a chip.
8. **The Arsenal's shelf.** Six machines over six Arsenal components (the Plasma Arquebus,
   Blazethrower, Meteor Artillery, Entropy Condenser, Oblation Ward and Retribution Thurible)
   leaves most of their stock borrowed. The stock pass may want two or three more Arsenal parts:
   a big single hit, a demonic shield.
9. **The trickle.** Six of seventeen chassis late-gated (the Arsenal has no tier one) changes
   nothing early, since the tender is the city makers'. Later, the capital's trickle offers a
   choice between machines rather than more of them.

## 4. What it costs

- **Content.** Four chassis and five fixed components, the three unbuilt passives marked
  planned, so the machines run without their passives as soon as they land. Misaru's runs today.
- **Engine, three pieces.** Burning passed on at a death (small: one hook at a foe's death, the
  neighbours in its rank). An ally's hull damage as a trigger (small: the hull-damage event fired
  on every other machine in the fight). The drag (medium: the slot swap, its forecast and its
  drawing, the save, the greedy bot's valuation).
- **Models.** Four lowforge functions with joints, four acts each and a gait, each a session or
  more of passes on Ryan's notes (the Nemesis took three). Two are new kinds: a heavy flyer, and
  legs on hoverjets with a hanging idle in place of a hovercraft's balance. The crawler is
  nearest the Ammit's rig. Each dies in the Arsenal's flames over a ghost, as built.
- **The runner.** Four new rows, and an Arsenal team row becomes possible (each maker's first
  three in content order); it should hold the Onryō, whose passive needs company.

## 5. What changes in the records once confirmed

- The bible's tone rows: the guardrail in hole 1.
- The bible's makers table and its nickname row: the Arsenal's builds (a creepy flyer, legs on
  hoverjets), its names, and the reason myth is the Arsenal's alone (the invasion is the JRPG
  bestiary now; the occult is the Council's).
- The component names row: the Arsenal's "medieval and slightly occult" becomes "medieval,
  demonic and eldritch", and section 12's question on "sanctified on the face" is struck.
- Section 7's chassis and motion tables: the four rows.
- `content/chassis.json`: the Arsenal maker's style line.
- The hangar page's Names and Rules tabs: the Arsenal plate, and the stale Rules line naming the
  retired foes (Ghoul, Necromancer, Pit Lord, the Maw).
- `docs/rules.md`: thirteen chassis become seventeen, and the drag if it lands.

## 6. The bench

Ideas set aside for these four, kept in case one is swapped:

- **The bell tower** (medieval): an assault walker with a bell caged on its back; its toll is a
  big indirect blow with Shock and Spread, a whole rank set up for the team's doubled blows.
- **Hubris** (the sins vein, and the Nemesis's own pairing): pride before the fall, strongest
  whole and weaker as it is hurt; hard to keep from binary.
- **The fate-edited die** (eldritch): its blanks reroll free until they show a component,
  redundancy against the Waste's theft; the hole is that a stripped die degenerates to one entry.
- **A veil** (eldritch): equipment that takes it out of the world for a round, waiting on
  Phased's design line (discuss first, bible section 12).
- **The sin-eater** (support): takes its allies' heat onto itself; the name is a person-noun, so
  it would need one from the bench of punishers.

## 7. Decisions for Ryan

1. The frame: the occult as the Council's register, held at plate and silhouette, liturgy in
   the shown text.
2. The names rule: "something that punishes" with a wider bench, or any demon.
3. Which machines, and in what order (Misaru can be built first; its passive runs today).
4. The names, the designations and the numbers.
5. The drag: Minos's passive alone, or a keyword.
6. Overcharged twice, or the Onryō's vendetta.

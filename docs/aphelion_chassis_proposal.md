# Aphelion: chassis proposals

The proposals of the Aphelion chassis chat, 11 to 13 October 2026, written down for a fresh
session to evaluate with every other proposed design as one batch (Ryan, 13 October: end the
discussion, build nothing yet, document the proposals fully). Nothing is in `content/` and
nothing is built.

This page states only what was said and checked in that chat: Ryan's brief and calls, Claude's
proposals in two rounds (11 and 12 October), the holes raised, and the engine and naming facts
checked along the way. It draws no comparison with other makers' machines or with other
sessions' pitches; the batch evaluation does that. Names, numbers, kit and model briefs are
placeholders for Ryan to move.

## 1. Where Aphelion stands

- **The maker** (`content/chassis.json`). Style: "Descended from the deep-space programme,
  back since before the rifts opened. Humanoid frames, hover platforms, variable geometry;
  high-tech suites over light hulls. White with a pearl sheen, red markings." Voice: "Haughty,
  elitist, technical, jargon". Names: primates, insects, sea creatures. Designations in its
  shape (Perihelion Flight 7 Support Frame, Perigee Flight 4 Strike Skimmer); "Frame" is
  Aphelion's word. Component names: physics nonsense.
- **Two chassis, both medium.** The Baboon (walker; the Pocket Paradox) and the Stingray
  (hover; the Exothermic Suite). Both stand at tier one since 11 October, "though both read as
  tier two until Aphelion has more chassis" (the bible's stock-pass row). The balance runner
  fields each maker's first three, so Aphelion has no maker row yet.
- **Its components.** Umbra Inducer (Suppress), Solar Flare Array (the Baboon's, locked),
  Photosphere Lance (the Stingray's, locked), Zenith Emitter, Halo Shield, Radiator Sail,
  Aurora Lattice (Primed), Differentiation Probe (Disrupt), Polarity Projector (Shock), Phased
  Sublimator (a cleansing vent); unstocked, the Corona Shield (Cleanse) and the Pulse
  Vacillator (Rapid).
- The to-do carried "Aphelion's next chassis (Ryan, 11 October: badly needed), proposed in
  chat first".

## 2. Ryan's brief (11 October)

> We need to spin up some more Aphelion chassis. Possible silhouettes: A medium flyer
> (StarCraft Science vessel homage?), a flying fortress (many options from helicarrier to
> capital-class spacecraft), a large hovercraft, a Gundam-homage walker. I think breaking the
> no-quads rule is worth it for a possible Zoids/lion force/power rangers homage.

The "no-quads rule" was the bible's makers table: Aphelion builds hovercraft and bipeds.

## 3. Ryan's calls (12 and 13 October)

Quoted where his words carry the call. The bible records them (section 6).

- **The makers table is a guideline.** "I'm treating the makers row as a guideline, not a
  rule."
- **The name families hold.** "A cat or wolf is out of Aphelion's naming register and those I
  kind of want to stick to, for sanity's sake if nothing else."
- **A fast walker.** "There's only two places a fast walker could fit - Aphelion and Arsenal,
  but both would be very different machines. However it's possible a sinister Zoid reference
  works as a homage in Arsenal. That's why this is a candidate, not locked."
- **Voltron and Power Rangers.** "I meant the individual machines in voltron and power rangers
  and not any sort of combining."
- **Transforming chassis.** Not a priority: hard to make read "without building a whole
  form-change system; which we certainly could do, but isn't a priority right now."
- **Rapid on a kill.** "The kill-turning-rapid as a feline/canine hunter mauling feels very
  Arsenal. Maybe that's a sign."
- **The Gundam homage.** "Can't be too on point. I'm fine trying it as described since I doubt
  we'll get full RX78 in our renderer, but as long as it has a shield, a handheld rifle, and a
  beam sword - it's a Gundam. That said, I think if any chassis wants to go all in on a
  tag-based passive, it would be this one with something 'beam' based." Tags are an incoming
  system (`claude/focused-ritchie-omn8i5`).
- **The Science Vessel.**
  - Area is no maker's alone: "Everything wants to boom."
  - "The stingray goes deep on status, this one goes wide."
  - "Could specify 'all non-damage effects' to narrow the range and bring the fantasy out of
    obvious damage carry applications."
  - "Otherwise, this sounds great."
  - "We will need a dispel effect, I'm not concerned about the keyword count, and the EMP is
    so core to this homage that it seems like a good fit. I'm not worried about getting back
    up, that can be changed if needed."
  - "It flies, so it should have an aquatic name, and a type of jellyfish works beautifully."
- **Propulsion.** "Aphelion doesn't use rotors as a general rule. They use thrusters, sci-fi
  space-age rockets. The stingray fans were to fit the silhouette." And: "the exposed rotor
  helicopter might go to W&S."
- **Long guns** (a machine joining fights from farther off). "I do like the long-guns ship idea,
  but considering that it's possible engagement range could change, it would be tough to
  balance it now."
- **The capital ship.** "What if the capital ship was the Protoss Carrier foil to the Minervan
  Terran Battlecruiser?"
- **The large hovercraft.** "Me trying to fill out the hovercraft roster, but we can park it for
  now."
- **13 October.** End the discussion; build nothing; document the proposals fully for a fresh
  session that evaluates every proposed design as one batch; note the Zoids reference and the
  open question of whether it is the Arsenal's or Aphelion's.

## 4. The proposals

Each as it stood when the chat closed, with what it replaced.

### 4.1 The line frame: the Gundam homage

| | |
|---|---|
| Status | Ryan: try it as described; its passive goes to the Beam tag |
| Tier, size, way, move | 1, medium, walker, 30 |
| Locked | the beam saber (round one); the kite shield (round two) |
| Hardpoints | the rifle as stock in a hand mount; the rest basic kit after the stock pass |

**Look (round one).** The first Aphelion frame that stands like a person: a V-crest on a small
head, chest intakes, a kite shield on the forearm, saber hilts on the backpack. Pearl and red
are already half the RX-78's colours. The homage lives in the silhouette only; it moves as the
bible says every machine moves ("Heavy and mechanical, with inertia. MechWarrior or Star Wars,
not Gundam or Evangelion"). Locking the saber and the shield (round two) keeps the read
whatever the player fits; the hand shows whatever is fitted to its mount.

**Passive, round one (superseded).** Gaining shield gives it a stack of Overcharged (+5 damage a
stack, fading a stack at the round's end): shield first, then strike, a sequencing call each
round, and any shield source becomes damage. Runs on today's engine (`on_shield_gain` with
`stack_status`). Replaced by Ryan's Beam direction.

**Passive, round two (open).** The hole first: a passive that reads one tag asks for every piece
carrying it. The bible says a chassis passive reads a tag only if it opens build space, no
machine has one straight-line build, and tags are read through soft synergies, never through a
threshold that makes one blueprint the build. Ryan's "all in" accepts a beam focus for this one
chassis. Two forms were offered:

- **Plain:** beam blows deal +5.
- **Claude's lead:** its beam blows deal +5 to a foe it has already hit this round. The rifle,
  then the saber: the payoff is any beam and the way there is any blow, and nothing carries
  past the round. That last point answered the bible's locked-pieces row as it read when the
  proposal was made (v0.114: "the next ones change another piece's reach, target or cost
  within the round instead"); Ryan has since revised the row (12 October, in the live v0.142):
  growth through a fight is fine for now, and what matters is that a machine's pair fits its
  identity.

**Optional locked pair (round two).** Spending the shield lets the saber reach any foe that
round (shield up, boost in): a locked piece changing another's reach within the round.

**Engine.** Tags on components first: today they carry the old internal filing tags and only
`melee` is read, though a `tag_<tag>` condition already works. The lead form needs a record of
the foes the machine has hit this round. The locked pair needs a reach change granted by a
spend for the round; `set_reach` exists only as a static passive effect.

**Names (round one).** Gibbon (the ape that walks upright); Snow Monkey (Japan's macaque);
Stag Beetle (the Gundam's V-crest is a samurai helmet's kuwagata, the crest the Japanese name
for the stag beetle comes from; an insect, where primates are the humanoid frames' family).
None is in `content/reserved_names.json`; "Stag" is a BattleTech 'Mech, and the validator
allows a shared word.

**Open.** The plain or the lead passive; the locked pair; the tier; the designation.

### 4.2 The jellyfish: the Science Vessel homage

| | |
|---|---|
| Status | Ryan: "this sounds great", with his narrowing and a jellyfish name |
| Tier, size, way, move | 2, medium, flyer, 30 |
| Locked | the EMP (round two) |
| Role | Ryan: it goes wide on statuses where the Stingray goes deep |

**The homage.** StarCraft's Science Vessel: Irradiate, Defensive Matrix and the EMP Shockwave.

**Look.** Round one: a slow sensor ship, a pearl dome under one great exposed rotor ring,
antennae trailing like a jellyfish; Ryan's propulsion call retired the rotor. Round two: a pearl
bell ringed with thruster nozzles that fire in pulses, sensor tendrils trailing.

**Passive, round one (superseded).** Every weapon it fires also hits the target's neighbours
(Spread on every weapon; it runs today as `grant_keyword` with `cleave`). Its status weapons
become area control: three foes suppressed, three shocked, each feeding the Baboon's Paradox.

**Passive, round two (Ryan's narrowing made exact; open).** "Every effect its weapons put on a
foe also lands on the foes beside it; its damage does not."

- The neighbours get what the target got, its Burning stacks included. Burn counts its stacks
  from the blow's damage, which the neighbours do not take.
- A spread Suppress meets each neighbour's own Numbed.
- A spread Lure turns three foes onto a light flyer: its risk, and a decision.
- Each neighbour that gains a status gains its own Paradox, so the Baboon's meter fills across
  a rank.
- Foes only: machines have no neighbours, and an effect on "every ally" would be a different,
  much bigger rule.
- Engine: new. No effect today carries a spend's riders to the foes beside its target without
  its damage.

**Locked: the EMP (round two).** Indirect, no damage, the dispel, and Shock so it is never a
blank entry against a pack with no buffs. In round one Claude had weighed an EMP and dropped it
(a new keyword, and stripping Getting Back Up a hard counter to the Marsh); Ryan overruled both.

**The dispel (decided by Ryan; its shape open).**

- What it strips, as proposed: a foe's own buffs. Today those are Folded (Harden), Kindled
  (Rally) and Getting Back Up (Reraise), which the engine tags `guard`, `rally` and `revive`;
  later the planned Protect and Shell.
- Numbed is out of its reach: the bible's rule is that nothing reads, deepens, spreads or
  cleanses Numbed.
- Its name: "Dispel" is Final Fantasy's own word, and the bible gives foe moves the genre's
  names while "the engine's words and the player's components keep ours". Proposed instead:
  Strip, or Purge (Purge pairs with Cleanse). Ryan's word was "dispel".
- A keyword, Ryan's call (the count is no concern): thirteen stand in bible v0.114, so the
  dispel makes fourteen. It starts on one carrier, a rare keyword in the way the bible lets
  Overshield stand.

**Names.** Round one: Moon Jelly, Jellyfish, Hoverfly. After Ryan's "a type of jellyfish":
Moon Jelly; Sea Wasp (a box jellyfish, and one of the Stingray's runner-up names on 2 October);
Crystal Jelly (the glowing jellyfish science learned fluorescence from); Sea Nettle. None is in
the reserved list; "Wasp" is a BattleTech 'Mech and a Halo vehicle, and the validator allows a
shared word.

**Open.** The spread rule as written (effects only, foes only); the dispel's name and exact
reach; Shock on the EMP; its stock; its designation.

### 4.3 The capital ship: the Protoss Carrier homage

| | |
|---|---|
| Status | Ryan's question: the Protoss Carrier, a foil to a Minervan Terran Battlecruiser |
| Tier, size, way, move | 3, assault, flyer, 20 (round one) |

**Round one, the flying fortress.** Ryan's brief ran from a helicarrier to a capital-class
spacecraft. The 28 September makers row (before the bible's rewrite) gave Aphelion's large
aircraft the register of "a deep-space thing". Proposed: a deep-space hull refitted with lift
fans in its deck, the helicarrier and the capital ship at once (the lift fans now retired by
Ryan's propulsion call). It could answer the bible's open lore question, "Did Aphelion come
back when the rifts opened, or before?" The hole: assault is the largest size class, so a
capital ship draws no bigger than any assault machine and reads as a frigate unless it is
allowed a bigger draw. Three verbs were offered, all new code:

- **The deck:** allies that end their turn beside it regain shield as if they had not fought.
- **The long guns:** it joins fights three hexes away. A machine's attack range is already a
  per-unit number (`Unit.attack_range`, 2 today). Ryan liked it and parked it while the
  engagement range may change.
- **A second die** for its air wing: the purest carrier, and the most expensive (two dice on one
  machine, on a phone screen).

**Round two, the Carrier.** Proposed as a design round of its own.

- **Ruled out when proposed:** interceptors that build up through a fight, by the bible's
  locked-pieces row as it read then (v0.114). Ryan's 12 October revision of that row (growing
  through a fight is fine for now; a machine's pair must fit its identity) reopens them.
- **Proposed, a screen:** a locked Launch Bay, equipment that gives every machine in the fight
  10 shield. A standing shield blocks a whole blow however small, so it stops one blow on each
  machine; a swarm's second blow lands, and a breach goes through. It would be the first
  equipment that reaches every ally: today equipment reaches itself, an ally, or either.
- **Considered:** interceptors as extra strikes on its weapons (many small blows, the target's
  armour coming off each one).
- **The foil:** Ryan framed it against a Minervan battlecruiser, so the two are best designed
  together.

**Names.** Round one: Nautilus; Narwhal (the tusk as a spinal gun); Sunfish. Round two: Whale
Shark (remoras for its interceptors), Nautilus, Sunfish. Refused by the reserved list: Man O'
War (BattleTech), Manta (Warhammer 40,000), Orca (BattleTech and Warhammer 40,000). Leviathan
is myth (the Arsenal's register) and a Warhammer 40,000 vehicle.

**Open.** Its verb (the screen, strikes, another); its passive; whether it is drawn bigger than
the assault class; its designation.

### 4.4 The fast walker: the Zoids homage, its maker open

| | |
|---|---|
| Status | A candidate, not locked (Ryan): Aphelion's or the Arsenal's |
| Tier, size, way, move | 2, medium, walker on four legs, 40 (round one) |
| Locked | claws (Direct, melee) |

**The homage.** Zoids first: a single beast machine. Lion Force Voltron and the Power Rangers'
zords are meant as their individual machines, never a combination (Ryan, 12 October).
Touchstones named in the chat: the Shield Liger, whose mane projects its shield; the Liger
Zero, which is white; the White Tigerzord.

**The maker question.** Ryan: a fast walker fits only Aphelion or the Arsenal, and the two
would be very different machines; a sinister Zoid could be the Arsenal's homage; and Rapid on a
kill, a feline or canine hunter mauling, "feels very Arsenal. Maybe that's a sign." The
no-quads line belonged to the makers table, a guideline now, so four legs are allowed for
either maker.

**Passive (round one).** A kill makes the spend Rapid: the entry switches off for the round, the
die rerolls free and the machine acts again. Kill order becomes tempo; strong into swarms, plain
against a boss. Unlike Chain, which repeats the same attack on the next target, the player picks
the next entry and target. Engine: Rapid exists; a kill as its trigger is new (there is no
on-kill trigger).

**Look and motion (round one).** A light, fast predator, never a box on legs. As Aphelion's: in
pearl and red, with emitters (round one also said flush fans, retired by the propulsion call).
Motion follows the bible:

- Machines are piloted, not animals: its acts are a pilot's (a scan through the head, the claws
  flexed, the mane charged), never grooming or a tail's swish.
- Heavy and mechanical: a heavy bound, not a cat's slink.
- Lowforge already builds four-legged walks and a gallop that can be reused.

**Names.**

- If Aphelion's (primates, insects, sea creatures; cats and wolves out): Lionfish (its spines
  as the Shield Liger's mane; the Stingray's other runner-up name on 2 October), Sea Lion.
- Offered in round one, out for Aphelion now (cats): White Lion (the Liger Zero is white),
  White Tiger (the White Tigerzord), Smilodon.
- If the Arsenal's (figures of myth who stand for justice and vengeance, never war), offered in
  round two: Sekhmet (the lioness whose vengeance nearly ended mankind), Haetae (the lion-like
  beast of justice that gores the guilty, from Korea and China).
- Refused by the reserved list: Lion (Heavy Gear), Cave Lion (BattleTech).

**Open.** The maker; the name and passive with it; the tier; the designation.

### 4.5 The large hovercraft: parked

Ryan: an attempt to fill out the hovercraft roster, parked. Round one had it at tier 2, heavy,
hover. Its holes: Aphelion's "high-tech suites over light hulls" sits against a hover tank, and
the Stingray already hovers. It would earn a place by taking whichever map verb the capital ship
does not; the deck suits a barge. Names: Manatee, Walrus, Cuttlefish.

## 5. Questions left for the batch

1. The frame's Beam passive (plain +5, or +5 on a foe it already hit this round); the
   shield-and-saber pair; its tier.
2. The jellyfish's spread rule as written (its effects, never its damage, on foes only); the
   dispel's name (Dispel, Strip or Purge) and reach; Shock on the EMP.
3. The Carrier's verb (the screen, strikes or another), designed with the Minervan
   battlecruiser.
4. The Zoids homage: Aphelion's or the Arsenal's, and its name and passive with the answer.
5. Aphelion's thrusters as a model brief: how they look.
6. Each chassis's designation in Aphelion's shape ("Flight n" and a job; "Frame" its word).

## 6. Recorded in the bible

- **v0.115 (12 October).** The makers table a guideline, the name families holding; Aphelion's
  propulsion (thrusters and space-age rockets rather than rotors; the Stingray's fans its own
  silhouette); a dispel strips a foe's buffs (decided; its name, carriers and numbers open;
  Numbed out of reach); an open row for Aphelion's next chassis; transforming chassis pinned;
  the large hovercraft and long guns parked.
- **v0.143 (13 October, merged onto the live v0.142).** The row for Aphelion's next chassis
  points here, with the Zoids homage's maker open; the dispel's reach marked as proposed;
  section 12's list of proposals for the batch points here.

## 7. What landing a pick takes

Once Ryan picks, in the commits that land each one:

- **Content.** The entry in `content/chassis.json`, and any new locked component in
  `content/components.json`. `design.fantasy` and `design.niche` come from this page; codex
  and flavour stay Ryan's. A passive the engine cannot run yet carries `"status": "planned"`.
- **The dispel.** In `content/vocabulary.json` before its code.
- **Engine.** The pieces named above, each tested with a synthetic passive.
- **Models.** A lowforge model for each, with its rig, acts and gait, judged running.
- **Records.** The bible's chassis table and `docs/rules.md`'s chassis count; the hangar page
  republished; a row each in the balance runner.

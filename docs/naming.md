# Naming

Ryan, 20 November, retiring the hangar's Names tab: "I think the names tab in the hangar can get
retired as long as you have the list of terms and names stored in a file somewhere. Those terms
should always have just been a reference of the TYPES of terms we want, not a comprehensive list."

So this is a reference of the kinds of names each maker wants, never a comprehensive list: a name
it lists is an example of its kind, and one it leaves out is not ruled out. The decisions behind
it are the bible's rows in section 7 (a nickname is a real Earth animal a player can picture;
each chassis has a dull maker's designation; names are ours, or a knowing homage; component names
follow each maker's vocabulary as a guideline); where this file and a row differ, the row stands.

The names floated on the old tab, 106 of them with who floated each and where they stood, are kept
as a record in `docs/name_candidates.md`.

Check a name with `python3 tools/check_name.py "<name>" ...`: an exact match against every machine
in BattleTech, Heavy Gear, Warhammer 40,000 and Halo (`content/reserved_names.json`) and against
the names in content now, and the reserved names it shares a word with.

## By maker

A maker's builds and names are its identity, a lean and never an exclusion (`CLAUDE.md`; the
bible's makers table, section 7): a piece is designed from its fantasy, and a word may cross
makers by its meanings.

### Minerva Heavy Works

- **Voice:** Maintenance manual. Terse, exact, proud of tolerances.
- **Builds:** Tracked vehicles (the monopoly on treads), heavy wheeled vehicles, quad walkers,
  perhaps heavy plantigrade bipeds, perhaps one heavy flyer in the battlecruiser register. Heavy
  machinery is the root, not mining alone.
- **Names:** Rugged terrestrial mammals: Honey Badger, Polar Bear, Wild Boar. Extinct is fine
  when the picture is common knowledge (Aurochs, Smilodon).
- **Avoid:** Digitigrade legs read too flimsy. The Musk Ox is Wainwright & Sutler's (21 October).

### Kestrel Dynamics

- **Voice:** Flight-test log. Clipped, numbers first.
- **Builds:** Small and mid-sized flyers and hovercraft. Nothing that touches the ground, nothing
  big. The monopoly on fast jets.
- **Names:** Birds. Raptors first (the Kite, the Buzzard), any bird with character after (the
  Puffin, the Skua, the Storm Petrel, the Needletail, the Lammergeier, the Giant Petrel, the Snowy
  Owl). The Puffin was wanted for the irony of what pilots called a hovercraft Kestrel thought was
  very cool.
- **Avoid:** BattleTech has eaten most raptors: Falcon, Gyrfalcon, Peregrine, Merlin, Osprey,
  Shrike, Raven, Eagle, Vulture, Kingfisher, and the Butcherbird; the Albatross is BattleTech's
  and Halo's, the Condor Halo's, a plain Owl Heavy Gear's. A bird too specific to picture (the
  Hobby, the Saker) is out too.

### Wainwright & Sutler

- **Voice:** Field notes. Dry and precise.
- **Builds:** Wheeled vehicles and quads (the primary source of both), perhaps a large helicopter
  or VTOL. No bipeds, no fast flyers.
- **Names:** The frontier's working animals and beasts of burden (Clydesdale, Prairie Dog, Musk
  Ox), and the frontier's threats: insects, arachnids, reptiles (Cottonmouth, Funnel-web, Whip
  Scorpion).
- **Avoid:** Nothing as generic as Tarantula or Desert Scorpion. BattleTech and Heavy Gear own
  most snakes and spiders: Rattlesnake, Sidewinder, Copperhead, Cobra, Viper, Adder, Gila,
  Scorpion, Spider.

### Aphelion

- **Voice:** Haughty, elitist, technical, jargon.
- **Builds:** Hovercraft, bipeds of every kind, perhaps large aircraft. Transforming designs
  undecided. No wheels, no quads.
- **Names:** Primates for the humanoid frames (the Baboon's family). Perhaps some insects. The only
  sensible home for sea creatures.
- **Avoid:** Mandrill is a BattleTech 'Mech that looks like ours, so it became the Baboon; Baboon
  is the Howler's Clan name, kept as a designation-tier clash. Langur is BattleTech too. Manta and
  Orca are 40k.

### The Arsenal

- **Voice:** A manual written as liturgy.
- **Builds:** Bipedal-ish walkers first, some large aircraft or hovercraft, always a little
  creepy. Silhouettes cross the other makers' lines: leg counts convert, legs ride on hoverjets,
  aircraft carry arms.
- **Names:** Never animals. Deities and beings of myth that stand for divine justice, vengeance or
  retribution (Nemesis, Ammit). A second vein of sins (Hubris) is unfleshed.
- **Avoid:** Never outright war, so no Ares. Spread across cultures: Egypt and Greece would
  swallow the list on their own.

### Components

- **Voice:** One piece of equipment, one entry on the die. Any word here is open to any maker.
- **Builds:** Weapons and equipment, and the shields and vents a locked piece still is. Names
  proposed here check against the same lists as the machines. A passive is named the same way: a
  device or a part of the chassis that does the thing (the Slipstream Projector, the Quintessence
  Reactor), never an ability.
- **Names:** The makers' vocabularies are guidelines, not claims (Ryan, 6 October; the bible's
  section 7). General words such as cannon, missile and laser belong to no maker, and a word may
  cross makers by its meanings (an Aphelion ion cannon; a Kestrel part ionizing something by
  speed). Minerva hits hard and low-tech: hurl, slam, smash, ram, launcher, flinger, hammer.
  Kestrel is propulsion and aerodynamics: booster, impeller, diffuser, mach, slipstream, wake,
  thrust. W&S is a plain military term beside something a little stupid or from the wrong period:
  carbine, gatling, howitzer, phalanx, repeater, flak. Aphelion is the physics and maths nonsense:
  entropy, subspace, solenoid, inducer, phase, neutrino, array, wormhole. The Arsenal is medieval
  and slightly occult, twisting the others' words: halberd, cleaver, talon, hellfire, hoarfrost,
  dimensional, arbalest. The pseudo-tech may contradict itself on purpose: a Polarity Projector, a
  Backwash Ionizer.
- **Avoid:** The reserved lists are machines, not weapons, so a clash here is a softer signal.
  Mind the over-words: the Overcharge Coil and the Overclocked Railgun are plenty.

### Other

- **Builds:** Foes, factions, places, anything without a home yet.

## How a name is read

The Names tab's Rules page as it stood on 20 November. Its decided parts are the bible's rows in
section 7, which stand where this differs; a maker's shapes and words are leans.

### What a nickname is

A real Earth animal, living or extinct, whose silhouette the player can picture without looking it
up. The name works because the picture rhymes with the machine: a Clydesdale is a big quad, a Kite
the light raptor that twists on its forked tail. Anomalocaris is real and fails the test; Aurochs
passes; a name too specific to picture (the Hobby, the Saker) fails too. No vehicle has an open
cockpit.

### Fossil over trope

The fossil record is on the table when it dodges the common trope. Dunkleosteus over Megalodon.
Aurochs over Mammoth (which is also a Heavy Gear strider). Smilodon over Sabre-toothed Tiger. A
Dodo because it is a funny thing for pilots to call a strange-looking machine. Dinosaurs
sparingly: they pull toward the toy register.

### Figures who punish are the Arsenal's alone

The Arsenal names its machines for figures who punish, from any culture (justice, vengeance and
retribution, Hell's wardens and avenging spirits among them; never war), never animals, so a name
tells the player which side of the makers built it: a mythic name on a city maker's machine would
blur that read, which is the reason and the whole of it. The invasion brings the genre's high
fantasy, and the occult is the Council's.

### Reading a clash

No chassis takes a machine name from BattleTech, Heavy Gear, Warhammer 40,000 or Halo; names are
ours, or a knowing homage.

- **Iconic:** the name alone conjures their machine. Warthog, Timber Wolf, Rhino for a wargamer.
  Never.
- **Known:** a hobbyist recognises it, mostly a Clan or Inner Sphere designation rather than the
  name people use. Judged case by case: Baboon (the Howler's Clan name) is kept this way, and the
  Dingo (a Heavy Gear gear) the same (Ryan, 29 September).
- **Coincidence:** a name every military reaches for, obscure in theirs. Kept.

The roster's two passes closed on 21 October: the Sparrowhawk (a BattleTech aircraft, a
coincidence) became the Kite and the Goshawk (an obscure nickname's) the Buzzard, their ids
following on 9 November; out with them the Shrike, the Merlin, the Gyrfalcon and the Peregrine
(BattleTech's), the Albatross (BattleTech's and Halo's) and the Condor (Halo's). The Butcherbird
turned out a BattleTech 'Mech's, so the strafer is the Skua; a plain Owl is Heavy Gear's, so
Kestrel's owl is the Snowy Owl.

The validator flags every exact match regardless of tier, and the entry records why a kept one
stays (`design.name_clash`). `tools/check_name.py` goes one step softer: a shared word is only a
nudge.

### Makers by shape

Each a lean, as the builds above are.

- **Treads:** Minerva only. **Fast jets:** Kestrel only. **Quads and wheels:** W&S first; Minerva
  may have both, Aphelion neither.
- **Bipeds:** Aphelion every kind, Minerva heavy plantigrade, the Arsenal bipedal-ish and creepy.
- **Hovercraft:** Kestrel small and fast, Aphelion platforms, the Arsenal legs on hoverjets.
  **Large aircraft:** Minerva a flying brick, Aphelion a deep-space thing, the Arsenal a creepy
  one; Kestrel one, the Lammergeier, its lean bending as leans do (21 October).

### Component names

Each maker's vocabulary is a guideline, never a claim: Minerva blunt, Kestrel air and speed,
Wainwright & Sutler plain military beside something silly, Aphelion physics nonsense, the Arsenal
medieval and occult, sanctified on the face and sinister on reflection. General words (cannon,
laser) belong to no maker, a word may cross makers by its meanings, and the Components section
above holds the maker-free names and lists each maker's register. A name is equipment, never an
ability; a passive names a piece of machinery or a part of the chassis that does the thing; the
pseudo-tech may contradict itself on purpose (that contradiction is the joke); a name approaches a
real thing without copying it (Trench, never Trench Gun); and the codex never explains the joke.

### Designations

Minerva an industrial catalogue code (EX-45XLE Combat Miner). Kestrel a type and mark (K-7 Mk III
Interceptor). W&S a pattern number (Pattern 1 Combat Walker). Aphelion a programme and flight
(Perihelion Flight 7 Support Frame). The Arsenal a decree (Arsenal Instrument IV). Each maker's
word for the thing is its own, Frame Aphelion's and Instrument the Arsenal's: a lean (the bible's
designations row).

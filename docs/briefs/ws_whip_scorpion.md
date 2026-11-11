# The Whip Scorpion: a rework

<!-- hangar: {"kind": "chassis", "maker": "wainwright_sutler", "tier": 2, "status": "rework", "slot": false, "name": "Whip Scorpion", "built": "whip_scorpion"} -->

**Ryan's direction (11 November)**: "Scorpion - a tougher one. The role was initially supposed to
be a spread damage dealer. I think we need to look at the built and planned roster, and see what
role it could fill, before just slamming some mechanics together." So the session opens on a role
map of the built and briefed roster, the hole it shows before any mechanic. Claude's note for it:
spread damage is crowded inside its own maker already (the Cottonmouth's drum, Spread at the front
and Penetrate at the back; the Musk Ox's barrage; the Prairie Dog's Flak on a cleave), beside
Kestrel's Lammergeier and Skua.

**Ryan's first thought on the form (11 November, after the role map)**: "have it 'pass' a turn to
release it's spent heat. Whereas before it would need to get vented by a component, that might have
a rider, now it would just have to sack the turn to release after the enemy turn. The only thing
that bothers me about that is the shape is very similar to the Buzzard pattern. The execution and
result is different, but their builds would functionally be similar, more or less, with some nuance
if the scorpion still wants to get hit or not." He asked for a look at what the Buzzard is for
first (it has had no review pass, and the Storm Petrel's rework steps near it): in chat, 11
November, his answer pending.

Wainwright & Sutler's sustained damage dealer at tier two, built and fielded (the bible's Whip
Scorpion row, Ryan's go of 20 October: "the boiler whose vents are its guns"): its Thermal
Ejection Manifold makes every vent it spends blast a random foe for the heat it takes off,
nothing else cools it, and its Heliographic Siphon lures every foe and banks a heat a blow. Its
rework was tabled on 3 November (its blast's random pick the one draw of the player's turn
besides the die) and Siphoning was left for it on 9 November. The refit pass sends it back whole
(`docs/briefs/refit_pass.md`): Ryan, 9 November, "send any machine or component or module that
clearly doesn't work in the new system (i.e. scorpion, for one), back to design."

## The role map (11 November)

Ryan's ask (11 November: "build me the scorpion data"): the built and briefed roster by role,
before any mechanic. Read from content at main's `827c95e` and from every brief's head; a
briefed design's role is its brief's direction, and a design still open is marked so. Claude's
reading throughout, for him to move.

**What the field sends** (`content/factions.json`, every domain's compositions):

| Tier | Pusher formations | Flanker patrols | Hunting packs | Elites |
|---|---|---|---|---|
| One | 10, about 7 heads each | 8, one or two heads | 7, about 2 | 6, about 2.5 |
| Two | 14, about 6 heads | 8, one or two | 8, about 2 | 15, about 2.7 |
| Three | 16, about 7 heads | 8, one or two | 8, about 2 | 15, about 2.7 |

Formations, a front that holds and a back rank that works, are the most common pack and the
only one of many heads, and their count grows with the tier; flankers are duels for one machine
(Ryan, 9 November: "One spooky flanker revenant or whatever is a more interesting duel for a
Skua or Kite"), hunters a catch.

**The roster by role** (built plain, *briefed in italics*, the tier as it stands):

| Role | Tier one | Tier two | Tier three |
|---|---|---|---|
| Front (a tank, a brawler) | Honey Badger, Polar Bear (going to two), Storm Petrel, *the lure tank* | Nemesis, Wild Boar (dives), *the echidna* | *the siege battery*, *the battlecruiser* |
| Damage on one foe | Cassowary, Stingray, *the line frame* | Kite, Buzzard, Nemesis, Funnel-web, *the Onryō*, *the Zoids walker*, *the gunship* | Ammit, Giant Petrel, *the thunder figure*, *the Macross* |
| Damage on many foes | Cottonmouth, Skua, Prairie Dog (light), *Static* | Wild Boar (a cleave and its spill), *the jellyfish*, *the Cryo party defence* | Musk Ox, Lammergeier, *Mastema* |
| Control | Baboon (going to two) | Dingo, *the time-shifter*, *Misharu* | *Minos* |
| Support, setup | Puffin (back in design, two his lean), *the Barrier and Ward support* | Needletail, Clydesdale (the sandbox), *the immune one* | Swallowtail (parked), *the Carrier* |
| Open | | *the mole* (one or two) | |

The Snowy Owl and the Magpie (Kestrel, tier open) are a stealth hunter and a support engine.

**Damage on many foes, by shape**:

| Tier | Machine | Maker | The shape | What feeds it |
|---|---|---|---|---|
| One | Cottonmouth | Wainwright & Sutler | Spread 2 at the front, Penetrate 2 at the back, every weapon | its drum, heat 3 a shot |
| One | Skua | Kestrel | Sweep, a shot a column, doubled | its split strikes |
| One | Prairie Dog | Wainwright & Sutler | Cleave 1 and Flak, a softener | Flak for the team's blows |
| One | *Static* | Aphelion | its status discharging into the foes round its carrier | stacks laid by every hit |
| Two | Wild Boar | Minerva | Cleave 2, a kill's excess into the rank behind | kills |
| Two | *the jellyfish* | Aphelion | every foe sharing a status with its target | the team's statuses |
| Two | *the Cryo party defence* | Minerva | Cryo blown everywhere, a little a stack | the team's Cryo |
| Three | Musk Ox | Wainwright & Sutler | Splash, a Sweep barrage | its forged ammo |
| Three | Lammergeier | Kestrel | a Mine's blast round a felled foe | kills |
| Three | *Mastema* | the Arsenal | fire passed from the dead to the living | kills, Burning |

At tier two the built roster has one machine whose identity reaches many foes, the Wild Boar,
and it reaches them through kills; the two briefed are payoffs of the team's statuses. Nothing
at tier two clears a formation by its own fuel, though tier two's formations outnumber every
other pack. Wainwright & Sutler reach many foes at tier one (the Cottonmouth) and tier three
(the Musk Ox) and not between. Damage on one foe at tier two is the most crowded cell.

**Heat, the Scorpion's fantasy**: the Stingray (stacks deeper with heat), the Buzzard (heat
into regen; the Afterburner fires it all, one foe), the Kite (runs hotter as it kills), the
Musk Ox (ammo in heat's place), the Polar Bear (the seal's clock), the Cottonmouth (a hot drum
shot), and two reworks waiting on the heat pass (the Storm Petrel's shield as it gains heat, the
Puffin moving heat between machines). The refit made the hold the heat decision (fire the
cold piece, keep the hot one, or pass and cool); no machine's identity reads the hold.

**Wainwright & Sutler's ten** (Ryan, 19 October: the maker is pure offence and utility; its
tier-one deal holds no front, accepted): the Prairie Dog a scout and softener, the Cassowary a
gunslinger, the Cottonmouth reach on many foes, the Dingo a car of two actions, the Clydesdale
the sandbox, the Funnel-web an ambusher, the gunship (rough), the Whip Scorpion, the Swallowtail
(parked) a helicarrier, the Musk Ox the artillery.

### The roles it could fill (Claude's, for him to move)

1. **The tier-two formation breaker.** Sustained damage on many foes from its own fuel, at the
   tier where formations grow and nothing built breaks one: closest to its first role ("a spread
   damage dealer") and its fantasy ("open the valves into the crowd"), and its slow heavy walk
   suits a lane a formation walks into rather than a chase. Its parting from the Cottonmouth
   (every weapon as area, tier one) and the Buzzard (heat fired as one blow) is its fuel and its
   price: heat held and released, the hold the refit asks for. The Siphon fits it as it is (every
   foe turned on it, braced, its fuel richest against a formation's many blows), the old
   condition kept (a machine that spends its turn to be struck and is paid later).
2. **Wainwright & Sutler's front.** The maker has none; the Siphon is a lure on every foe and its
   body is heavy. But being struck is the roster's most crowded orbit (the Nemesis's rage since
   11 November, the Onryō, the echidna, the lure tank; Misharu's and the Cryo party defence's
   triggers open since their directions of 5 and 6 November) and the fronts are Minerva's and
   Kestrel's, four built and briefed.
3. **The back rank's breaker.** A formation's casters behind its wall: reached today by Indirect
   pieces, the Cottonmouth's Penetrate, Expose (the Needletail, the Lammergeier, the
   Swallowtail's flare), the Dingo's Swap, and Minos stalled. Covered in pieces, and a formation
   breaker can carry it as its shape.
4. **The machine of the hold.** A rule that reads the heat decision itself, over every maker's
   pieces (the identity test: a new read): a role within role one rather than beside it.

Claude's lean: the first, with the fourth as its engine, so the role is the hole and the heat
pass's hold is its read. The mechanics wait on his pick of the role.

## Why the model breaks it

- No vent face stays on the die, so there is no vent to spend: its guns are gone. Its stock
  carries two Coolant Jackets, which retire.
- Its fuel rule stood on a cooling of zero ("nothing else cools it"), a kind the model has no
  other example of, and on vents as the one way heat left it.
- His shapes of 3 November for the rework all stand on vents too (a vent, or an ally's vent,
  giving a temporary buff; the Siphon's heat on a hit moved to its passive; one strike to the
  blast a vent in the turn), so they go back with it.

## What stands

- The fantasy, in his words: a future-tech machine that behaves like a steampunk device, the
  boiler, "a sustained dps engine"; heat is its ammunition and the fuel is a decision, never a
  drip; run hot on purpose, whistle at the swarm, open the valves into the crowd.
- The Siphon's counter-profile (the heat a blow poor against a boss and good against a swarm), if
  the Siphon stays; its Armoured for the round fits the model as it is.
- Its body, its model's second round and its place in the maker's ten.

## First thoughts, Claude's, for his session (nothing here is proposed as content)

- **The hold is the valve.** The model's heat decision is the hold: fire the cold piece, keep the
  hot one, or pass and cool. A boiler could turn that round: it never cools, and every piece of
  its own it leaves unspent as its turn ends opens a valve, a blow of so much heat off the gauge.
  The player then reads its die as guns to fire and valves to leave shut, which is the
  deliberate trigger finger he wants from heat, on the one machine built round it.
- **A locked valve.** One fixed weapon that fires its heat (the Buzzard's Afterburner Cannon is
  this already, "one blow that fires it all"), so it would want a second idea to part them: the
  valve's blow by rounds held, or by the foes that struck it.
- The blast's target: his row made the random pick the rider's limit; the randomness pass wants
  it aimed or laid by a rule the player can see. His call with the form.

## Holes raised

- Without a cooling of zero the boiler is any hot machine; with it and no valve it is unplayable.
  The form has to carry its own way down.
- "Its vents are its guns" was a rule over other makers' pieces (any vent became a gun), the
  build space of the old design. The new form wants a rule over pieces again, not one locked
  weapon, or the chassis opens no build space (the bible's identity test).

## What the session hands back

Its passive and its locked piece as a first round in chat, his marks, then content with the refit
pass's content; its runner row beside the Buzzard's; its model unchanged unless the form asks.
Until then it is not dealt once the pass's content lands (its passive marked planned).

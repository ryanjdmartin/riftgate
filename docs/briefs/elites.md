# The elites: filling the holes

A brief for a session of its own (Ryan, 2 November: "Write a brief to spawn a session to fill
in elite holes, and we can have more Wanderers or move some of our existing into Wanderers if
they fit"). It holds where the elites stand, what Ryan has said, what the engine gives an elite
today, the holes by domain, and Claude's first round of candidates, unanswered: every candidate
is proposed in chat first and lands as a placeholder kit for his marks, as the slate's bosses
did. Read `CLAUDE.md`, `docs/rules.md` (the battle's Fractures and elites), the bible's tiers
row and boss-mechanics row (section 9) and `docs/bosses_proposal.md`'s elites table first.

## Where it stands (2 November)

An elite (Ryan, 23 and 24 October; the bible's tiers row) is a spawn of one or more unique
packs outside the usual spawn lists, a mini-boss tier: a visible curveball that demands the
player adapt, by a mechanic on the map (a dangerous hunter, a fast blitz on the gate, a sudden
swarm, an aura or a battlefield effect) or by being a harder fight that threatens the gate while
it holds the team. It is the guaranteed miniboss event of every battle, worth more of the
Rupture meter and Anathema than a pack (its menace doubled).

Built (30 October to 2 November):

- An elite is a foe flagged `elite` leading an `elite` composition (`content/factions.json`),
  at the tiers the composition names. At the Fractures the tier names (tier one's first; tier
  two's first and third; tier three's first, second and fourth: `Ramp.ELITE_FRACTURES`) the
  lead domain's next own elite not yet sent this battle emerges at the rift
  (`Battle._spawn_elite`), or a wanderer.
- A wanderer (`wanders`: Gilgamesh, `gilgamesh_wanders`, listed once under the Waste) is drawn
  by any domain's Fracture one time in three (`ContentDB.WANDER_CHANCE`, a placeholder) in
  place of the domain's next own, and always once the domain's own are spent
  (`ContentDB.next_elite`; the roll from the battle's seed, so a resumed battle rolls the
  same). The quick campaign's elite slots draw the same way.
- Elites may come again in a later battle, never twice in one; a run never repeats a boss
  (Ryan, 2 November).
- Every elite stands at the battle's tier as a boss does (`ContentDB.scale_boss`: HP ×1.25 and
  ×1.5, attack +1 and +2; Ryan, 2 November: "Scale the elites by tier"), the other members of
  its composition at their own numbers.

The roster today, by domain and the tiers its compositions name:

| Domain | Elites | Tiers | Holes |
|---|---|---|---|
| The Meadow | the goblin shaman's warband; the Elder Treant's grove; the Leshy's hunt | 1–3; 2–3; 2–3 | none by count; one at tier one |
| The Waste | the Old Man of the Desert's rising (the king sandworm); Gilgamesh, the wanderer | 1–3; 1–3 | a Waste hunter (Ryan's mark, 24 October); one own at every tier |
| The Marsh | the Reaper, a hunter; the Bone Wyvern's flight | 1–3; 2–3 | one own at tier one; a third |
| The Peak | none of its own | — | everything: today Gilgamesh comes at its every Fracture |

Ryan's hope (2 November): at least three elites per domain, so a wanderer never has to fill a
hole, and the wanderers themselves more than one.

## Ryan's words

- 23 and 24 October: the definition above; the Reaper's mechanics may work on the map by
  definition, as a deadly hunter; the Elder Treant and the Leshy as the Treant's harder-fight
  elites, the Leshy free to be a foe of its own for diversity; the king sandworm the Old Man of
  the Desert (Dune's plain words, which the homage rule lets stay).
- 2 November: "Elites can be reusable, if that wasn't clear. Bosses no, but elites can, just not
  in the same battle obviously. Wanderer doesn't have to be 'if none left' since I would hope
  that we end up with enough elites to make that statement false regardless of reusing or not
  (i.e. at least 3 elites per domain)."
- 2 November, the flee rule: "Don't give foes flee unless its like a treasure-goblin
  equivalent, and those on flee would flee the battlefield entirely, so its a
  pop-it-for-loot-before-its gone kind of deal. Don't know that we need that archetype, but
  thats the only time I would say to have flee." So no candidate here flees; the loot-runner is
  the bench's.

## What the engine gives an elite today

So every kit below is buildable as content alone, or names the one piece it would need:

- A composition: the elite and any members of the ladder at its tiers, at the ramp's density.
- Every implemented foe move effect (`content/foes.json`'s `_about`): a blow with factor,
  strikes, swarm, countdown, breach, scorch, burn, disable, corrupt, self_destruct and all; brace,
  brace_all, regrow, regrow_ally, revive_once, revive_once_ally, summon, rally, drain_rerolls,
  silence, dispel (a purge), cleanse, barrier, regenerate, ward_all, prime, steal, swallow, merge,
  drain, per_kill, once; a follow-up (`then`); a condition (`when`); an aim; a boss in parts with
  or without a guard, parts that grow back; a last act; a split on death.
- On the map: push (toward the gate) or hunt (one machine, locked at spawn: nearest, weakest,
  strongest, slowest, fastest), zone, movespeed, winged.
- Not built: the map mechanics the fantasies ask for beyond these (a blitz on the gate, a
  swarm that keeps coming, an aura or a battlefield effect such as shields that stop
  recharging or terrain changed; the to-do's line), and the planned effects (flee, interpose,
  retaliate, regrow_all).

## Claude's first round of candidates, unanswered

Names of ours under the homage rule (a series' coinage takes a name of ours; a myth's word or
a plain word stays). Each is one line of fantasy, its slant (a hunter, a harder fight, a map
curveball), a kit from built pieces, and what is open. Nothing here is decided.

### The Peak (three wanted, none built)

1. **The Mother Bomb** (Final Fantasy IV's Mom Bomb by archetype; a harder fight). A massive
   Bomb that counts down to Self-Destruct at every machine, and splits into Bombs as it falls
   (`on_death` summon, as the Gel splits): the Peak's telegraph in a body that is itself the
   telegraph. Kit: Swell (brace, +1 a round); Detonate, a countdown of three, self-destruct, at
   every machine, Scorch 2; on death three Bombs step up. Open: whether the split's Bombs act the
   round they land (the Gel's halves do not).
2. **Cerberus** (the three-headed hound, a myth's name; the Peak's hunter). Hunts the weakest,
   zone 2, movespeed 3: three bites a round (strikes 3), Burning on each; below half, Howl, a
   rally. Open: whether a hunter that fast on the map is the "fast blitz" Ryan named, or too
   much at tier one.
3. **The Fiend of Fire** (Final Fantasy I's Marilith by archetype, the six-armed serpent in the
   volcano; a harder fight, armour 1). Six Blades, six strikes of a small number, each paying
   armour, so plate answers it; below half, Fire at every machine, Scorch 1. Open: six strikes
   against a shield (the first strike pops it, five reach the hull).

### The Waste (a hunter wanted; the Old Man and the wanderer stand)

1. **The Coeurl** (Final Fantasy's whiskered panther; the hunter Ryan marked). Hunts the
   fastest machine, zone 2, movespeed 3: Blaster, a disable on the entry the machine shows,
   and a bite through the shield. Open: whether the Waste's theft of entries wants a hunter or
   a wall; a hunter that takes the die's best entry each round is a tempo check.
2. **The Roc** (the great bird, a myth's name; winged, so walls and water are nothing to it).
   A map curveball: it crosses the wall the team holds and hunts the slowest. Swoop, two
   strikes; Sandstorm, drain_rerolls. Open: the first winged elite, so the map's wall rule is
   read against it.

### The Marsh (one own at tier one; a third)

1. **The Dullahan** (the headless knight, a myth's name; Final Fantasy VI's by archetype; a
   harder fight, armour 2). Cleave, two strikes; Headless Charge, a countdown of two through the
   shield; Rise Again (revive_once when hurt). Open: whether the Marsh's third is a harder fight
   or a map curveball, which the Reaper already is.
2. **The Reaper to the wanderers** (Ryan's "move some of our existing into Wanderers if they
   fit"): death walks anywhere, and a deadly hunter is the curveball every domain can carry.
   Open: it would leave the Marsh one own at tiers two and three (the Bone Wyvern) and none at
   tier one, so the Dullahan comes first if it moves.

### The wanderers (more than one)

1. **The Iron Giant** (the genre's wandering armoured giant with the great sword, plain words):
   a harder fight anywhere, armour 2. Great Sword, a blow
   of 10 on a countdown of one; Guard, brace +2. Open: a second wanderer at the same chance, or
   the wanderers' pool drawn one at a time in content order (as built: the first not yet sent).
2. **Enkidu with Gilgamesh** at tier three: Gilgamesh's companion joins his composition's
   tier-three row (a member `enkidu` 1), a beast that mends him (regrow_ally) and rallies. A
   cheap add, since a composition's members may differ by tier.

### The bench

- **The loot-runner**: the treasure goblin's shape, the one flee Ryan would allow (2 November),
  the archetype he is not sure is wanted. If it comes: an elite that carries salvage, flees the
  battlefield entirely after N rounds or at a Fracture, pays double salvage killed and nothing
  escaped, says so on the plaque before it goes. Waits on the flee effect and on his call that
  the archetype is wanted.
- **The Mimic**: a chest that bites, the same deal without the flee: a harder fight that pays
  extra salvage. Pinned until the economy pass reads salvage.

## Questions for Ryan

- Three a domain confirmed as the floor, and which of the candidates above are in, out, or
  reshaped (his notes against them first).
- The wanderer's chance: one in three (the placeholder), or a wanderer slot of its own at one
  Fracture a battle.
- The Reaper to the wanderers, or not.

## What the session hands back

Each elite in content as a placeholder kit with its composition at its tiers, placeholder art
where no render is picked (`tools/placeholder_art.py`), a test where a mechanism is new, the
bible's tiers row and section 9 table, the rules' Fractures paragraph, the proposal's elites
table, the hangar and the bible page republished, and this brief retired to git.

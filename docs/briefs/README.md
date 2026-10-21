# Design session briefs

One brief for each chassis proposal, chassis direction and rework that came out of the roster
analysis (`docs/roster_analysis.md`) and Ryan's go on it, 14 and 15 October. Each is the
starting point for a design session of its own: where the design stands, what Ryan said and
when, what Claude proposed, what is open, the holes already raised, and what the session hands
back. A brief retires to git once its decisions are rows and content, as a proposal does.

Ryan, 15 October: mechanics nobody has discussed must not muddy a handoff. So the briefs hold
only what was proposed and discussed in the records and the chat; anything new is proposed in
chat first.

## How a session runs

- Read `CLAUDE.md`, `docs/rules.md`, the bible's first row (`docs/design-bible.html`), the
  "Start here" of `docs/status.md`, this file, then the brief and the files it names. If a chat
  and a file disagree, the chat is newer.
- Each brief is the design's one home. The three makers' proposal files were folded into
  their briefs on 15 October and retired, with `docs/mechanic_budgets.md`; git keeps them
  (`git show 2df9340:docs/arsenal_proposal.md`, and likewise `ws_chassis_proposal.md`,
  `aphelion_chassis_proposal.md` and `mechanic_budgets.md`) for the names offered, the retired
  rounds and the full arithmetic, all of it written under the old whole-block shield rule.
  The roster analysis's sections 1 to 11 predate the go too: where a brief and the analysis
  differ, the brief is newer.
- Propose in chat first. Ryan tweaks ideas against his own notes; a suggestion of his opens a
  discussion, so look for holes and raise them before building. If he reaffirms after hearing
  them, build it as he said.
- Mark whose words are whose: Ryan's calls carry his name and the date; everything else is
  Claude's proposal for him to move.
- Names, numbers and looks are Ryan's. He matches mechanics to silhouettes he has in hand;
  propose a name or a look only when he asks. Every number is a placeholder.
- On Ryan's go: the bible's rows (each decision with its reason and the condition that would
  reopen it), `docs/rules.md` where a rule changes, content with `"status": "planned"` where
  the engine cannot run it yet, the to-do ticked, `docs/status.md` updated, the bible
  republished. Nothing is built before the go.
- Landing a chassis also takes: its locked pieces in `content/components.json`; a new keyword
  in `content/vocabulary.json` before its code; engine pieces tested with synthetic passives;
  a lowforge model with its rig, acts and gait, judged running (a new model kind where the
  frame needs one); the bible's chassis table and the chassis count in `docs/rules.md`; the
  hangar page republished; a balance-runner row, read alone as a diagnostic.
- Sessions run in parallel on this repository: diff a shared file before staging it, and read
  the bible's live page before republishing it (the status says how).

## Decided on 14 and 15 October

Rows in the bible and lines in `docs/rules.md`; built only where a line says so.

- **The shield rule.** A shield absorbs its number and the excess passes to the hull; a breach
  ignores the shield outright (the shield stands); an injury counts what reaches the hull.
  Under the old whole-block rule a tiny shield was secretly "negate one blow", and every new
  shield design was heading for that margin.
- **Barrier and Ward**, two buffs. A Barrier: the next blow a foe lands on the machine deals no
  damage (so it never injures), its riders landing, until the round's end; never granted to
  every ally at once. A Ward: every blow a foe lands on the machine that round leaves no rider,
  breach included, while the damage lands (Ryan: it lasts the round because it is more
  situational). Both up is the old whole block at twice its price. Ward is the buff's word, so
  the Oblation Ward becomes the Oblation Mantle (in content, 15 October) and the Votive Ward the
  Votive Screen.
- **Cooldowns**: a printed property on specific pieces, shown on the entry as dark with the
  rounds left. Ryan: nearly every Rapid component reads "Rapid, cooldown 1", and the Nemesis's
  fists are simply Rapid. No cap on where a cooldown goes or how many a die carries (Ryan, 15
  October: a cap is artificially limiting).
- **The Dingo's Megataser Harpoon** carries Shock in place of Suppress (in content, 15 October).
- **Misharu's payoff is Penance**, a weaken, in place of Suppress.
- **Kestrel's gaps**: the strafer at tier one and the bomber above it.
- Agreed in chat, for the HUD: a suppressed foe's intent line clears (Ryan's point, 14
  October; built 15 October, the hold readout the last place it showed).
- **The budgets** (15 October): hard control weighed and never capped, and three tests kept
  (below).

## Ryan's taste, as the go established it

- Elegant over complicated. He pushed back each time a design grew a second mechanism ("this is
  taking off into complicated territory"); one passive, one idea; complexity belongs to the
  higher tiers.
- Never an unkillable team by another name: no team-wide armour, Braced or shield handed out in
  bulk ("giving the team tank stats is just as toxic as taking all the blows").
- No reward for being struck that scales with the enemy's blows (the old discharge). A thorns
  tank is balanceable only if the thorns carry a drawback of their own, and rewarding a tank
  for doing its job (being struck under a draw) is dangerous. The condition that reopens it
  (Ryan, 20 October, the Whip Scorpion's Siphon): a machine that spends its own turn to be
  struck, deals nothing that turn and is paid later and at random is not a tank doing its job.
- Niches can and should overlap across a larger roster so a player finds something that fits;
  mechanics should not repeat, and a mechanic is its pattern in its context, never one trait it
  shares (Ryan, 16 October: a random target in two pieces is no repeat; "if you say 'can't do
  this thing because that already kind of does it,' then you quickly run out of things").
  Ryan, 18 October: "in a roster of up to 50 units, there's going to be role and mechanic
  overlap. The trick is making the shape of each different enough that they create a unique
  enough feeling."
- Reroll-related effects are Kestrel's (Ryan, 19 October, after sending them to Wainwright &
  Sutler on 18 October: that maker's ten filled without effort): "it actually fits, and means
  we can push Kestrel way into the risk-versus-reward space, like a real maverick pilot."
- A tier-one body from more than one maker takes the pressure off the Armadillo being a
  must-pick (Ryan, 19 October: Wainwright & Sutler is pure offence and utility, Aphelion to be
  decided), which is why the Kestrel off-tank takes a tier-one slot with a lure of its own;
  Aphelion also needs a defensive tier one (Ryan, 19 October), a line in the to-do for its
  session.
- Random is welcome where it adds and the player can steer it (the bible's section 2, Ryan,
  16 October).
- The foes' debuff vocabulary is thin at four words (Burning, Suppressed, Shocked, Paradox;
  Numbed is a resistance), which is why designs keep reaching for Burn or Suppress. New chips
  are fine, even unique to a chassis, since tooltips and popups carry them. The vocabulary
  grows by kinds (a weaken, a flat on-hit, a share of current hull, a timed stun, a trapped
  slot), never by copies.
- Stun is budgeted; prefer changing the enemy's problem over removing its turn. Price, never
  scarcity (17 October, of Suppress): a mechanic rationed by availability makes its carriers
  must-picks, so it is priced so the other answers stay attractive. The price is a gate, never
  the damage it deals (18 October): a condition, a setup, a self-sacrifice or its timing, so a
  stun is planned for rather than reacted with; the Paradox is the model.
- Rapid pieces stay small; a damage rider on an action the player takes anyway needs a limit.
- The action economy (Ryan, 20 October; the bible's row beside the stun row, section 5): Rapid
  is the new Suppress in build ubiquity, so it is priced by a gate and never rationed, and each
  of the wants it sells gets a home that is not a Rapid piece (the section below). A design
  that wants many blows is pointed at strikes; one that wants order is given a die mechanic;
  one that wants a second action pays in a banked resource, a cooldown or an ally's turn.

## Tiers

- **Ryan's counts** (14 and 15 October): about ten chassis per city maker at the top end, split
  3-5-2 or 4-4-2 across tiers one, two and three (18 October, of Wainwright & Sutler: eleven is
  too many); tier three late-game capstones, so few; the
  Arsenal in reverse, little access early and much late. Ryan, 15 October, in the Minerva
  session: Minerva's two tier threes are a treaded capstone and a capital ship, "the capital
  ship that it seems like every maker is going to end up getting".
- **The sort** (Claude's, partly agreed): tier one is itself with basics alone and stands in a
  start (a body or a hitter, not a support); tier three bends a rule the player has already
  learned; the rest is tier two, where the supports and the machines that are only good
  together belong. Ryan reads the Baboon as tier two; the Dingo is tier two with its
  Translocator (19 October).
- **As dealt**: the tender offers one tier-one machine of each city maker by seed and the
  player takes three, so each maker's tier-one pool should vary and more than one maker's deal
  should hold a front. The host maker's offer after a win and procurement's shelf deal the
  higher tiers; the economy items the go raised are in `docs/economy_pass.md`.
- Each brief gives a proposed tier; none is decided but Wainwright & Sutler's (20 October, the
  bible's roster row: 3-5-2). The reshuffle proposed so far: the Wild Boar to tier one; the
  Baboon to tier two (the Clydesdale, the boiler, the revolver, the fan-boat and the Dingo are
  settled by the maker's row). The 12 October basic-kit row no longer gives every tier one a
  locked piece (reworded 20 October): a tier one shows its identity with basics alone, with a
  locked piece or without (the Cottonmouth; the form-changing Armadillo keeps its lure by
  Ryan's framework of 15 October).

The tiers as the briefs propose them (nothing decided; "down" and "up" against a chassis's
tier today; the targets two or three tier ones a city maker, two or three tier twos and one
tier three, the Arsenal none, three and three):

| Maker | Tier one | Tier two | Tier three |
|---|---|---|---|
| Minerva | Honey Badger, the Armadillo as a form changer, Wild Boar (down) | the echidna (the hedgehog) | the H-tank (the siege battery), the battlecruiser |
| Kestrel | the strafer, the shield-spender (the off-tank package: plate, burn, a lure that regens itself; Ryan, 19 October), the interceptor (its first weapon each round Rapid; Ryan, 18 October: a great tier-one design) | Goshawk, Puffin, Sparrowhawk (up, the caster-killer proposed 19 October) | the bomber (Ryan, 15 October; heavy and the capital ship proposed), the gun platform (the team's rerolls as its passes, proposed 19 October) |
| Wainwright & Sutler (decided 20 October, the bible's roster row: 3-5-2) | Prairie Dog, the Cassowary (landed), the Cottonmouth (landed) | the Dingo (tier one in content until its Translocator's engine), the Clydesdale, the funnel-web (landed), the gunship, the Whip Scorpion (landed) | the Swallowtail (landed 21 October), the artillery (the ammo build, briefed) |
| Aphelion | Stingray, the line frame, the Zoids walker if it is Aphelion's (its brief proposes two) | Baboon (up), the jellyfish | the Carrier |
| The Arsenal | none | Nemesis, Misharu, the Onryō, the Zoids walker if it is the Arsenal's | Ammit, Mastema, Minos |

## Budgets (Ryan, 15 October)

Decided on the roster analysis's budgets; the bible's rows hold them.

- **Hard control**: adding it (a foe losing its action) is always carefully considered, and
  other options explored, before it is suggested or committed to. The analysis's caps (no
  hard-control piece below tier two, at most one locked on a die, one hard-control passive a
  maker) are struck as artificially limiting. The bible's stun row (section 5).
- **A new chassis earns its place** by a new read, a new product, a new price, or by changing
  what a kind of piece does; niches can and should overlap, so the test reads the mechanics
  (section 7).
- **A passive aims** to be fed by, and to feed, other makers' pieces, ideally two routes in and
  two payoffs: an aspiration, never a pass or fail (section 7).
- **A tier one shows its identity** with basics alone (section 10).

## Roster holes, as the go left them

Soft control: Minos, the jellyfish, the echidna's draw, the Armadillo's locked lure, filling.
Amplify for others: the Dingo's Shock, Flak (the Prairie Dog's Flakshot, the maker's on-hit,
19 October), the echidna's Sonic Needle; the Onryō's Grudge finds another shape.
Area on a hardpoint: the stock pass's explosives, the strafer's volume, the bomber's clusters.
New prices: the cooldown, negative cooling. Reads nobody used: the foes' intents (the spider),
the slots (the bomber), the die's own state (the revolver, the Gundam, the battlecruiser), the
team's rerolls (no taker since Ryan refused them as the Armadillo's payout, 15 October;
Kestrel's, Ryan, 19 October: the gun platform proposed in `kestrel_gun_platform.md`).
The tender: Kestrel's deal varies with the strafer; Wainwright & Sutler's holds no front
(Ryan, 19 October: the Cassowary is squishy on purpose, accepted, the Clydesdale down the lever
if one is ever wanted; a planned chassis is never dealt, so its deal is the Prairie Dog or the
Dingo until an engine lands); Aphelion's with the line frame. Wainwright & Sutler's
versatility comes in three forms (Ryan, 19 October): the Clydesdale's loadout, the gunship's
stats, the Cottonmouth's reach.
Damage dealers (Ryan, 18 October): Wainwright & Sutler had none, its sponsorship counting
damaging spends while no chassis was about the blow; the revolver and the boiler are promoted
to damage class. Ryan, 20 October: the all-shells machine pitched in the Minerva session for
the siege battery (its third-round candidate: weapons that add no heat and cost a shell each,
vents that reload, the heat gauge a magazine; `minerva_siege_battery.md`) reads to him as a
Wainwright & Sutler tier three; Claude agrees it is this maker's artillery tenth (the cold
price the heat row asked for, on the maker whose kit is cold; no other machine is its loader,
Ryan, 21 October): `ws_artillery.md` (20 October; Ryan's shape 21 October). The old-world artillery of the maker's lean (indirect fire and area) is
nobody's chassis: its second tier three and its tenth, the last (big Indirect blows with area,
the stock pass's explosives its kit, mobile where Minerva's siege battery sits on the cooldown
property), undesigned.
Every maker fields every tier it may once the gaps land. The foes' debuff vocabulary grows from
four words by kinds, never by copies: Penance (a weaken), Grudge (a flat on-hit), Venom (a
share of current hull), the web (a timed stun), the mine (a trapped slot); and Barrier and Ward
on our side.

## The action economy, and why things want Rapid (20 October)

Ryan, 20 October: "Do you think there's a case to be made for trying to expand the ways to
fill a rapid-type niche? After all, action economy is often a chase in these styles of games.
Commander actions are one obvious area. Do a deep dive into why certain things want rapid,
and what we could change or add to help fill that gap other then add a ton more rapid pieces.
Which we can and will do, but it will feel samey regardless." And: "rapid is turning into the
new Suppress in terms of build ubiquity." Claude's analysis, the same day, for Ryan to move;
nothing here is decided.

Rapid sells five different wants in one keyword, and it is the only component-level source of
any of them, which is the Suppress pattern (one answer, so every design reaches for it):

| The want | Who chases it | What Rapid gives it |
|---|---|---|
| another look at the die | the Cassowary (a roll is a step), the gun platform (a roll is growth), the Armadillo (fishing for the seal or the lure), the Pulse Vacillator's own niche | the free reroll |
| a second action on one machine, setup then cash | the Armadillo (seal, then act), the Cassowary (the Rapid before the chamber it doubles), the interceptor, the Puffin (vent an ally and still act), the siege battery (reload and still act) | act again |
| spends counted | the line frame's combo (weapons spent), the Cassowary's sixth shot, the Paradox (once a spend) | more spends a round |
| a small effect that costs no turn | the Deflector, the Diffuser, the Flakshot (lay Flak, cash it the same round) | the cantrip |
| tempo lent to the best machine | the multi-rotor, the Cottonmouth (a Rapid shell is two drum shots) | an action moved |

Four of the five carriers in content are ungated (the Deflector, the Diffuser, the Vacillator,
the Flakshot: the switch-off and nothing else), the Umbra Inducers of tempo; the gated ones
(the Spin-Up by its cylinder, the interceptor's once a round, the Zoids walker's by a kill)
are the Paradox's shape. The stun row's cure applies: price by a gate, never ration.

Homes for each want other than more Rapid pieces, with the engine's state:

- **Own rerolls as a number** (another look). The engine runs it: the Clydesdale's Battery
  Director is one free reroll of its own die a round, a static effect a module may carry
  today. Give it to the machines whose identity reads its die (the Cassowary, the platform,
  the Armadillo), as a passive clause or a priced module (its stat line paid elsewhere, so it
  is no universal must-pick). A look without an action. Hole: the Clydesdale's identity thins;
  the number is the lever (one on a d9 is not one on a d3).
- **The team's order instead of self-sequencing** (the second action). A passive that needs
  Rapid pieces to work wants a second action; ask first whether an ally's action is the better
  pair (the Dingo's Shock to the Sparrowhawk's cash, the off-tank's lure for the team). Where
  the self-sequence is the identity, give it a die-order mechanic (stepping, a combo), as the
  Cassowary has.
- **Counters that count blows, not spends** (spends counted). A counter per blow makes
  multi-strike and area pieces its fuel, Wainwright & Sutler's currency, where a counter per
  spend makes Rapid its fuel. Flak counts blows; the line frame's combo is open (count blows
  landed, and the Maxigun is a combo piece); the Paradox counts once a spend by decision.
- **Combined entries** (the cantrip). Two effects on one spend: the off-tank's lock (a lure
  that regens itself), the Afterburner (damage and vent all), the harpoon (damage and Shock),
  the Flakshot. The stock pass's cantrips can be combined entries rather than Rapid ones: a
  vent that shields, a shield that lures, a gun that vents on fire. Density a spend instead of
  count of spends: no reroll, no chain, nothing to limit, the price each half's number.
- **Rolls again, paid in a banked resource** (the second action, priced). The Nemesis's rule
  (spend a stack, the die rolls again, no switch-off, the stacks the limit) as a family, one
  banked resource a maker: rage, the hopper's loads, Spun Up, the H-tank's shells, Overcharged,
  Kestrel's heat (roll again for 20 heat) or its rerolls. A plain roll, a visible price, gated
  by its setup.
- **Cooldown bursts** (the second action, front-loaded). Two actions' worth in one spend, then
  dark: strikes 2 with a cooldown of 2, the broadside, the Sparrowhawk's chain. Paid in the
  die's reliability; the cooldown property (decided, not built) unlocks the family.
- **Delayed actions** (an action moved in time). The bomber's mines, the web, and a charge kind
  (arm now, fire twice later), which reads the die's own state.
- **Reactions** (actions in the enemy's turn). Retaliate, the Barrier, the web's burst; a
  counter-battery (when a foe acts on an ally, this machine's showing weapon fires at it, once
  a round) with the thorns row's caution: a reward that scales with enemy actions needs a
  drawback.
- **Tempo lent as a status** (tempo lent). A haste buff from a support (the ally's next weapon
  spend gives its turn back) moves the chase from pieces to supports and prices it in the
  support's action; Rapid by another name, ranked last.
- **Commander actions** (the campaign scale). The bible: the commander's tools do what
  machines cannot (manipulation, mitigation, information, movement, never a fifth gun; a
  reusable ability deals no direct damage); battlefield abilities belong to the city, on
  map-turn cooldowns, legible and impossible to hoard, research shortening them; the layer
  waits for a baseline balance. Action economy fits movement and manipulation: a sortie (a
  machine that fought moves again), a scramble (every flyer moves), a field refit (one own
  reroll a round in its next skirmish; "no command die rolls" says the commander has no die,
  and a granted reroll is a manipulation to confirm against the row), a fire mission (a
  one-shot with damage on the map, never in a skirmish). Flavoured by the host city's maker:
  Kestrel's city gives tempo, Minerva's plate, Wainwright & Sutler's the strike, Aphelion's a
  teleport, the capital's a blood price. Action economy nobody can stack, the opposite of a
  Rapid pile.
- **Pricing the Rapid that exists** (the stock pass). The four ungated carriers re-priced (heat
  on the Vacillator and the Flakshot, the Deflector's number, the Diffuser's question in
  section 12), and every new Rapid gated like a stun: if it kills, on a cold spend, once a
  round, by a cylinder.

The three rules of thumb this leaves: a design that wants many blows is pointed at strikes;
one that wants order is given a die mechanic; one that wants a second action pays for it in
a banked resource, a cooldown or an ally's turn. Rapid stays for the cantrip, gated.

## The briefs

| Brief | Kind | Maker | Proposed tier | Waits on |
|---|---|---|---|---|
| `minerva_armadillo.md` | rework, in session | Minerva | 1 | nothing |
| `minerva_honey_badger.md` | rework, in session | Minerva | 1 | nothing |
| `minerva_hedgehog.md` | direction, in session (the echidna) | Minerva | 2 | nothing |
| `minerva_siege_battery.md` | direction, in session (Ryan's H-tank) | Minerva | 3 | nothing |
| `minerva_battlecruiser.md` | direction | Minerva | 3 | the Carrier's session (the foil); the cooldown property |
| `kestrel_strafer.md` | decided; proposed for the go, 18 October | Kestrel | 1 | Ryan's call on the proposal |
| `kestrel_shield_spender.md` | direction; three kits proposed 18 October, the off-tank package on Ryan's word 19 October | Kestrel | 1 | Ryan's call on the package; its runner row on the shield rule's engine |
| `kestrel_bomber.md` | decided; proposed for the go, 18 October (Ryan happy with the whole; heavy proposed) | Kestrel | 3 (Ryan, 15 October) | Ryan's call on heavy and the numbers |
| `kestrel_gun_platform.md` | proposal (19 October) | Kestrel | 3 | Ryan's call on the gimmick |
| `kestrel_sparrowhawk.md` | rework, direction (Ryan, 18 and 19 October) | Kestrel | 2 (from 1) | the cooldown property; a Kestrel tier one landed for the tender |
| `ws_boiler.md` | landed 20 October as the Whip Scorpion, retired (`git show 82ff916:docs/briefs/ws_boiler.md`) | Wainwright & Sutler | 2 | its engine and assets (the to-do); the stock pass's heat prices |
| `ws_revolver.md` | landed 19 October as the Cassowary, retired (`git show 021f075:docs/briefs/ws_revolver.md`) | Wainwright & Sutler | 1 | its engine and assets (the to-do); the stock pass's Rapid prices, for its balance |
| `ws_multirotor.md` | landed 21 October as the Swallowtail, retired (`git show 5d989be:docs/briefs/ws_multirotor.md`) | Wainwright & Sutler | 3 | its engine and assets (the to-do); the mark's rider from the Kestrel session |
| `ws_artillery.md` | in session (the Musk Ox, Ryan's calls of 21 October) | Wainwright & Sutler | 3 | the stock pass's explosives and heat scale |
| `ws_funnel_web.md` | landed 18 October, retired (`git show bfa8cf2:docs/briefs/ws_funnel_web.md`) | Wainwright & Sutler | 2 | its assets (the to-do); its engine built 18 October |
| `ws_gunship.md` | proposal | Wainwright & Sutler | 2 | the stock pass's tags |
| `ws_fan_boat.md` | landed 19 October as the Cottonmouth, retired (`git show 021f075:docs/briefs/ws_fan_boat.md`) | Wainwright & Sutler | 1 | its engine and assets (the to-do) |
| `ws_prairie_dog.md` | landed 19 October (Flak), retired (`git show f5a085a:docs/briefs/ws_prairie_dog.md`) | Wainwright & Sutler | 1 | Flak's engine (the to-do) |
| `ws_dingo.md` | landed 19 October (the Combat Translocator), retired (`git show 021f075:docs/briefs/ws_dingo.md`) | Wainwright & Sutler | 2 (1 in content until its piece's engine) | its engine (the to-do); its stock with the stock pass |
| `aphelion_line_frame.md` | direction | Aphelion | 1 | nothing |
| `aphelion_jellyfish.md` | direction | Aphelion | 2 | the foes' fresh start (foes with several moves) |
| `aphelion_carrier.md` | proposal, open | Aphelion | 3 | the battlecruiser's session (the foil) |
| `aphelion_baboon.md` | rework | Aphelion | 2 (now 1) | the stock pass |
| `zoids_walker.md` | proposal, maker open | Aphelion or the Arsenal | 2 (1 if Aphelion's, in the reshuffle) | nothing |
| `arsenal_misharu.md` | proposal | the Arsenal | 2 | nothing |
| `arsenal_onryo.md` | direction | the Arsenal | 2 | nothing |
| `arsenal_mastema.md` | direction | the Arsenal | 3 | the foes' fresh start (riders on machines) |
| `arsenal_minos.md` | proposal | the Arsenal | 3 | the foes' fresh start (back ranks) |

Not briefed here: the large Aphelion hovercraft (parked by Ryan; below); the empty slots toward
each maker's ten (later maker sessions); cantrips (Ryan's idea of small Rapid pieces with no
cooldown, a component for the stock pass, noted in the line frame's brief); the Scapegoat Brand
(a rare after the vocabulary pass, half of it now Mastema's mover: in Mastema's brief); enemy
Shock on machines (none today; Claude's lean, if any: on a hero or an elite, telegraphed, never
the rank and file; the foes' fresh start); the economy items (`docs/economy_pass.md`); the
engine work (the to-do).

## Benches and parked ideas from the retired proposals

Ideas the makers' proposals set aside that belong to no single brief, one line each with what
set it aside, so Ryan can overrule the reason and not only the idea. A chassis's own bench is
in its brief; the full rounds are in git (above).

**Aphelion**

- The aura-shifter (Claude, 18 October, proposed for Kestrel as a mode-shifter of its shield,
  three locked shields each a tuning that holds while it stands; Ryan, 19 October: it reads as
  an Aphelion tier three, "an all-in aura support, maybe, with shifting auras for the team"):
  for an Aphelion session, beside the Carrier.
- The large hovercraft, parked by Ryan (12 October: "Me trying to fill out the hovercraft
  roster, but we can park it for now"): proposed at tier two, heavy, hover. Its holes:
  Aphelion's "high-tech suites over light hulls" against a hover tank, and the Stingray already
  hovering; it would need a map verb the Carrier does not take (the deck suits a barge).
- The long guns, parked by Ryan (12 October: "I do like the long-guns ship idea, but
  considering that it's possible engagement range could change, it would be tough to balance
  it now"): a machine joining fights three hexes away; attack range is already a number on
  each unit (`Unit.attack_range`, 2 today).
- The time-shifter (Ryan, 17 October, from the funnel-web's session: "There might be an
  Aphelion machine that wants to control the battlefield by delaying and redirecting blows,
  some kind of spacetime manipulator. Soft control, moving or delaying hits as a whole
  identity."): delay (a foe's next move gathers a round, the countdown as built, so the blow
  lands late and dies with the foe) and redirect (the blows meant for a machine re-pick by the
  foes' aim, held rather than lost when no one else stands, the phase its action for the
  round). Holes for its brief: delay alone is tempo and the fight's last blow, so it pairs with
  burst; a redirect onto a chosen ally is an interpose by proxy, which the redirection row
  allows on a locked piece only; our countdown chip on their foe must read as ours; it parts
  from the jellyfish by pattern (the jellyfish changes the move and dispels; this moves the blow
  in time and target).
- The burrow, grown on the spider and moved here (Claude, 17 October; Ryan: "hilarious", and
  "is this actually a broken ability, shuffling all intents away?"): equipment on itself,
  every foe aiming at it re-picks. Broken on the spider (with Rapid it deletes the ambush
  limit, a locked piece feeding only its own passive; alone, blows lost would be a free stun)
  and a reverse Lure without the choice for the ally; sound as the time-shifter's shift with the
  two fixes above.

**The Arsenal** (Claude's, 11 and 12 October)

- Haunted: a striker spends its next blow on the foe beside it; a novel verb (foes turning on
  each other) that does nothing against a lone boss.
- The guardian's stay: a blow that would wreck an ally leaves it at 10 hull; rare, binary, and
  close to the Honey Badger's open identity.
- The bell tower (medieval): an assault walker with a bell caged on its back, its toll a big
  indirect blow with Spread, Penetrate and Shock; set aside for the four on 11 October, no
  other reason recorded.
- Hubris: strongest whole, weaker as it is hurt; hard to keep from binary.
- The fate-edited die (eldritch): its blanks reroll free; a stripped die degenerates to one
  entry.
- A veil (eldritch): out of the world for a round, waiting on Phased's design line.
- The Misericorde: the first Onryō's mercy dagger (Direct, flat 10, heat 5, Rapid), free for
  another Arsenal machine.
- The four as a set: one for each of Ryan's words (medieval, demonic, eldritch, sinister) and
  four reads (a shield breaking, a blow reaching hull, a burning death, its own reach); with the
  Nemesis and the Ammit, three at each of tiers two and three. Pairs to watch: the Votive
  Screen feeds Misharu (each Screen spent is a fresh shield that may break); Minos lines burning
  foes up for the Bellows. A team row once the four exist: Misharu baits, Mastema burns, Minos
  arranges, the Onryō punishes.
- Retired with the shield rule: the proposal's "only a breach sets off Misharu and the Onryō
  with one blow"; a breach now breaks no shield, and any blow above the shield breaks it and
  wounds.

**Wainwright & Sutler** (11 to 13 October; the reasons Claude's unless marked, Ryan's to
overrule)

- Fighting without having moved gives Spread: set aside, since a map action that buys a fight
  buff is free.
- Crags as slow ground: set aside, since a map rule alone is weak.
- A kill makes a spend Rapid: set aside as an Arsenal machine's shape (the Zoids walker's brief
  carries it).
- Every weapon Indirect: set aside as free reach once danger close goes (decided 11 October,
  not built).
- Indirect weapons strike twice: set aside as dangerous as written.
- Shield as a spider's ammunition: set aside while Misharu turned shield into damage; Misharu's
  payoff is now Penance (Ryan, 14 October), so the idea is free again.
- Debuffs as the gunship's sights and the fan-boat's drift: set aside (Ryan, 12 October:
  statuses are Aphelion's strength, and a gunship is about its weapons; 13 October: statuses are
  never Aphelion's alone).
- Two tests from those rounds (Claude's, 13 October): a passive that is pure upside with no
  interest fails (the fan-boat's Ballistic splash); so does a payoff not worth its setup (the
  gunship's missile-marked reach).

## A suggested order

1. Nothing to wait on: the Minerva session (the Armadillo, the Honey Badger, the echidna, the
   H-tank; in session since 15 October); then any of the strafer, the shield-spender, the bomber,
   the line frame, Misharu, the Onryō and the Zoids walker (its maker first); the funnel-web
   landed on 18 October, the revolver (the Cassowary), the fan-boat (the Cottonmouth), the
   Dingo's Translocator and the Prairie Dog's fight half on 19 October.
2. In pairs: the battlecruiser and the Carrier together (Ryan's foil); the Baboon with the
   stock pass.
3. After the stock pass: the gunship; the multi-rotor landed on 21 October as the Swallowtail, the
   boiler on 20 October as the Whip Scorpion.
4. After the foes' fresh start: the jellyfish, Mastema, Minos.

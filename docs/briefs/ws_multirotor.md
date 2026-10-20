# Brief: the multi-rotor (proposal)

The session finishes the large multi-rotor whose die any machine in the fight may spend as its
own.

**Status**: rework (Ryan, 20 October, below: the lending design is abusable and a boring combo
piece; the helicarrier angle is the direction). **Maker**: Wainwright & Sutler.
**Proposed tier**: three. **Read first**: `docs/briefs/README.md`; `docs/roster_analysis.md`
section 4; its look below, rendered in `docs/looks/ws_multirotor.png`.

## The design (the proposal, with Ryan's calls)

"Any machine in the fight may spend its die as its own": that machine's passive and buffs
apply, and it pays the heat and any bite. Its die is dropped on an ally's to hand it over for
the round. Nothing locked; six hardpoints; its loadout is built for the team. The look is
settled (Ryan, 13 October): the helicarrier deck.

The rest of the proposal (12 and 13 October; Claude's unless marked Ryan's):

- **The shown text**: "Any machine in the fight may spend its die as its own." The rule it
  bends: a machine spends only its own die. "As its own" carries the rest, so the shown text
  stays one sentence and the codex says so in a line. The Sutler's Manifest is the passive's
  working name. The word "die" in shown text waits on another session (Ryan, 13 October: the
  dice look like no dice, the problem that kept "face" out of shown text).
- **What it opens**: a loadout built for the team: flat guns for the Sparrowhawk's double
  damage, hull-biting kit for the Nemesis's rage, stack appliers for the Stingray, shields for
  the Puffin, status pieces for the Baboon. A sutler supplied an army in the field: the maker's
  own name, in the air. It supplies and never launches, which leaves launching to Aphelion's
  proposed Carrier.
- **The gesture**: its die dropped on an ally's die hands it over for the round, and that
  machine spends it as usual; dropped anywhere else, it is spent by itself. The bot chooses the
  spender by its forecast.
- **Engine**: a spend by another machine: the die handed over for the round and spent as the
  spender's own (its passives and buffs on the blow, its heat and any bite paid), the hand-over
  undone at the round's end; the forecast and the bot read the spender's numbers; the hangar
  and the codex say whose die it is while it is lent.
- **Numbers and kit** (the proposal's placeholders, set under the whole-block shield rule):
  assault, flyer, move 20; hull 170, shield 50, armour 5, heat 80, cooling 5, field
  recharge 15. Nothing locked: its kit is the team's. Six hardpoints (a d6). Its stock, today's
  pieces as stand-ins for the stock pass: the Howitzer, the Enfilade Beam, the Maxigun, the
  Incendiary Shells, the Laminar Deflector, the Coolant Jacket.

### The look: the helicarrier deck (Ryan, 13 October)

Ryan chose it from three looks built in lowforge and rendered through the game's own 3D view
(`docs/looks/ws_multirotor.png`; the models are look tests in
`tools/lowforge/looks/ws_multirotor.py`, never content). The V-12 is cool too, without the
wagon cover, and is kept for another machine; the tandem is set aside (Ryan, 13 October). The
look as built, its joints and acts proposed (Claude's, from his choice):

- **Homage**: the helicarrier played straight, in Wainwright & Sutler iron: a flat deck held up
  by four rotors in rings at its corners.
- **From above**: a long flat iron deck with a blunt bow, a centre line in hazard dashes and a
  hazard landing square aft; at each corner a rotor in an iron ring on an arm from the hull,
  blades drawn as blades. It reads as a multi-rotor at once, the biggest footprint of the
  three.
- **The hull**: a keel slung under the deck, slab sides of riveted iron (`steel.panel`) with a
  warm brown band (`livery.livery2`), amber lamps at the bow (`amber.light`).
- **The island**: on the starboard edge, a riveted block with the bridge glazed round
  (`glass.glass`), a roof, a mast with an amber lamp and a stack.
- **The mounts**: six round the deck's edge and at the bow, bolted on and squared off, all
  reading from above.
- **The crane**: at the stern, a little to starboard of the centre line, a mast and a jib
  swung aft, a hook on a line hanging below the hull: the tell for the passive (Ryan, 15
  October: as the look builds it).
- **Size and float**: assault, so it overflows its hex, drawn south over north. Nothing touches
  the ground; only the hook hangs low.
- **Joints and acts**: the four rotors spinning (`b.spin`), faster under way; the crane's yaw
  and luff, the hook swinging; the mounts' yaw within the turret rule. Resupply: the crane
  swings out, the hook drops and rises. A battery drill: the mounts traverse in turn. A gust: a
  corner dips, its rotor bites, the deck rights itself and settles.
- **Under way**: the helicopter style, unpinned at last: it holds its facing and tilts into its
  travel, heavy and slow to start, barely a bank.
- **Death**: Wainwright & Sutler's winding down, the rotors spooling to a stop.

## Ryan's question in the go, and the answer (14 October)

Ryan: "if an ally uses its die, thats the rotor's turn used up, right? so its like letting an
ally go twice at its own expense?" Then: "I just want to be clear that when its ability is
used, WHO gets their turn consumed?"

Claude: the rotor's. A die is spent once a round either way. The ally spends two dice, its own
and the rotor's, and its own is untouched; the rotor spends none. The ally pays the lent
entry's heat and any bite, so a Sparrowhawk spending a lent flat gun doubles its own heat, the
natural brake. A lent Rapid entry gives that ally a further lent spend. Each round the rotor
picks one spender for its one entry. Ryan's simplification holds: from one angle it gives an
ally two turns in a round, one of them not on its own die.

## The analysis (14 October)

The roster's clearest "only good together" machine and the purest support; alone it is a plain
d6 with no passive, the lowest floor in the game, which tier three allows. Under the stun
budget it multiplies nothing by itself: a lent stun is still one stun.

## Ryan's direction (20 October): the helicarrier

Ryan, 20 October, on the lending design: "It might need a complete rework, the more I think
about it the more ways I find to abuse it, and really, it's not all that interesting at the end,
just a boring combo piece." Claude's reading of the abuses: the gate is hollow, since the rotor's
own turn is the price and its kit is built to be lent and never fired, so what is left is a
second action every round for whichever machine amplifies it most, an obvious pick (flat guns
for the Sparrowhawk's double, a lent vent for the Whip Scorpion's blast, Volatile kit for the
Nemesis's rage, lent spends counting toward the Cassowary's sixth shot); the action-economy
row's "tempo lent", ranked last.

Ryan, the same day: "I think we need to lean into the helicarrier angle, as it represents the
apex of steampunk-silly military technology. What does a helicarrier (or aircraft carrier in
contemporary terms) do? It carries things, obviously, but it also operates as a mobile command,
and fire support. It doesn't rain death, but it directs units to rain death, offers in-fight
refueling and support, and gives them a lift when needed. There's an angle there, for sure, and
leaves the undesigned artillery capstone to fill the raining-death niche completely."

Claude's reading, the same day: the four verbs and their homes in the game. Carry: the map
(machines ride the deck over any ground at its pace). Command, directing fire: a marked foe
every ally's weapon reaches this round whatever its rank (the observer calling fire; a reach
rule bent at tier three, where a rule the player has learned may bend), paid with the carrier's
own spend. Refuel and support: equipment spent on allies, the row's cantrip (a vent that
shields). Lift: extraction from a fight is the withdrawal, not built and not encouraged
(section 4), so the lift lives on the map. Two framings:

- **A, the commander's deck** (Claude's lean): the carrier brings the commander's actions to
  the battle, the action-economy row's own home for tempo "nobody can stack": map-turn verbs on
  cooldowns, never a fifth gun (section 8): a sortie (an ally lifted its full move again, the
  carry), a field refit (an ally sheds heat and regains shield on the map), a scramble (the
  next fight's allies reach any rank, or a called strike). In the fight it is a plain die of its
  hardpoints with support stock, nothing locked, so it never enters the fight's tempo at all;
  the decision is which verb, when, on its cooldown. It makes the commander exist, which the
  battlefield layer has wanted since section 8. Its hole: the commander's layer is undesigned,
  so its session designs the first three verbs, and the campaign runner's plain player uses no
  map verbs until taught.
- **B, the command deck in the fight**: the carry as the map passive; two locked pieces, Fire
  Direction (spent on a foe: every ally's weapon reaches it this round) and Resupply (vent 20
  and shield 20 on an ally, a combined entry); four hardpoints, a d6, so each round it directs,
  supplies or fires, one spend. Its price is its own turn, which is real here because its guns
  are worth firing. Its hole: Fire Direction undercuts the Cottonmouth's reach in a team that
  carries both, and the reach it lends the Cassowary's doubled shot at a back-rank caster is
  the kind of pairing a capstone is allowed.

Either way the artillery tenth keeps the raining-death niche, the roster row's slot holds (the
multi-rotor's name retires; the chassis's is Ryan's, a frontier flyer or pest in the maker's
register), and the look stands because it fits, never because it is built.

## Open for the session

1. The framing (A or B, or Ryan's own), its name, then its design in full: the verbs, their
   costs and cooldowns, the numbers, the engine (the commander's layer for A; a spend that
   grants reach for the round and the carry for B).
2. Its shown text, which waits on what shown text calls a machine's die (a session of its own;
   Ryan, 13 October), if any of it names the die.

## What the session hands back

A proposal in chat; on Ryan's go, content planned (a spend by another machine is engine work,
and the bot must choose the spender), and this brief retired.

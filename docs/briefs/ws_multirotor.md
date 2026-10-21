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

Ryan, 20 October, later: "Carrier is in the same boat, I think it wants a map passive (one
maker identity) and a combat passive, as I don't think there will be enough build hooks on
locked components alone. I like the map passive half as something simple like 'units adjacent
to the carrier travel with it.' Grants other units extended range, over otherwise difficult
terrain, and is a culmination of the makers map-centric abilities. Only issue is being able to
drop units on mountains, so that needs a solve. I'm not sure what kind of form an in-battle
identity could be. The extreme would be outfitting allies with new abilities, a more refined
version of the die-lending we had before."

Claude's reading, the same day. The map half as Ryan has it: machines adjacent to the carrier
when it moves travel with it. The solve for the mountains: riders are set down on the nearest
hexes they can stand on around where it stops (the field already finds one), and the carrier
cannot stop where a rider cannot be set down, so it flies over the crags and lands beyond them
when its move spans the band. The lift is the rider's move: a carried machine may still fight
from where it is set down but does not move again, or the carry is a free second move for
the whole squad every turn, the Dingo's identity handed out in bulk. The carrier's move sets
the reach (a flyer: 30 or 40, every ground normal), and the squad bunches, one fight for all,
which is the carry's price and the maker's map identity brought to its end. The combat half,
two candidates: the Manifest (the sutler supplies the field: at a fight's start each of the
carrier's supply pieces goes onto one ally's die for the fight, the hangar saying which to
whom; the ally's die grows by one, no extra action, the lent piece firing with the ally's own
passives, so the old pairings return at die odds, once a fight, with nothing to chain and no
obvious pick each round; the carrier fights with its locked pieces and what it kept), or
spotting (a foe the carrier has hit this round is in every ally's reach whatever its rank, the
observer directing fire: its own target choice is the decision, and it changes the enemy's
problem). Claude's lean: the Manifest, the outfitting Ryan named as the extreme, with the
build hooks he wants (which piece to which machine), the lending's combos kept and its
tempo abuse gone. The chassis's one passive object carries both halves as one idea, the
supply ship that carries the squad and outfits it, within the three effects a passive may
hold.

Ryan, 20 October, later, on the carry: "The point of the carrier carrying would be to give
extended reach. It doesn't count as their action, otherwise you wouldn't be able to move a unit
to get on the carrier, and then the carrier moves. Its not a reset, though. If it picks up an
adjacent unit that hasn't acted, then on landing that unit can still move and attack. If a unit
moves to it to get picked up, I think its ambiguous if that unit can then fight after from
where it lands, I'm not sure if that makes sense or if its just confusing UI. It doesn't step
on the dingo because the dingo can still act twice AND hop on the carrier in one round, so its
the only one that can drive, get picked up, and then drive again. I don't anticipate the
carrier having a lot of move points, that's the point. It's just a little bump, getting a unit
over a river or a mountain, or repositioning so that they can reach that side pack just out of
reach. Its meant as a strategic piece, not a movement abuse, its tier-3 power." On the
Manifest: "setting it up in the hangar would be impossibly complex. Literally not tenable.
However, I think a variant might have merit: Two of its hardpoint slots are 'equipment' slots.
When those faces come up, the carrier can drag them onto another units die to give it to them
for the duration of the skirmish, then both dice reroll." And four locked-slot ideas: a mark
(from the Kestrel session's brainstorming: the target reachable by any weapon and taking extra
on-hit damage this round, a new debuff, Exposed; the interceptor gets it free with its Rapid,
so the carrier's wants another rider to be worth a whole non-Rapid spend); a resupply (an
ally's shield to its maximum, heat to zero, cleansed; a long cooldown); a revive (a scrapped
unit back with full shield and 10% hull, once a skirmish; unsure whether it is a dangerous
commander ability, perhaps fine as a die ability, or both); all units dock (every other ally
Phased this round, perhaps cleansed, every enemy lured onto the carrier; the one-unit form,
one ally docked and its attackers lured, he reads as stronger, a game-swinging risk).

Claude's reading, the same day. The carry as he has it, the lift leaving the rider's action
exactly as it stands: a rider that has not acted lands and may move and fight; one that moved
to board keeps whatever move it had left and its fight, since the round already lets a machine
move in pieces and fight after (the lift changes where it is, never what it has left), and the
map draws its remaining ring from the landing hex, which is the UI answer to the ambiguity.
The set-down rule stands (the nearest standable hexes; the carrier cannot stop where a rider
cannot be set down). The carrier's move 20, two hexes as a flyer: the bump. The Dingo's two
actions and the lift compose as Ryan says. The equipment slots: the Manifest at die time, with
its own gates: a hand-over only when the slot's entry shows, once per piece a skirmish (the
piece leaves the carrier's die and joins the ally's for the fight, so the carrier's die shrinks
as it outfits), the reroll of both dice its cantrip half, bounded by the two pieces; the slots
take equipment (a shield, a vent, a buff: the refuelling and support Ryan named), so a lent
flat gun on the Sparrowhawk, the old abuse, cannot happen, and a lent vent on the Whip
Scorpion, the hook he wants, can; the hangar chooses only which two pieces ride in the slots,
which is any loadout. The mark: the reach half (reachable by any weapon this round) is the
observer's and new; the on-hit damage half is Flak's kind (a point a stack on every blow),
so Exposed and Flak would be one kind under two chips unless Exposed is reach alone, which
goes to the Kestrel session that is designing it; the carrier's rider over the interceptor's:
duration (until the marked foe's next action rather than the round), which a non-Rapid spend
can carry. The resupply: fine under the cooldown property (not built), which the capstone may
carry; not team-wide, so the unkillable-team line is clear; the Whip Scorpion declines it. The
revive: a die piece once a skirmish is the safer form (the die's odds and the carrier's spend
gate it, where a commander verb is a guaranteed reset); it bends "damage sticks" (section 4) at
10% hull, which a tier three may, and the foes' Risen is its mirror; Claude's lean: a brief of
its own rather than this ship's first kit, since three verbs are already a capstone. The dock:
the late-dock trick is the hole (every ally acts, then docks for a free immune enemy turn at
the carrier's hull's expense), so the dock is the opening act or nothing: only while no ally
has spent this round, so its price is the team's whole turn, Darkest Dungeon's planned turn;
Phased (planned, Aphelion's: cannot attack nor be damaged until the round's end) is the status
it grants; two lure-alls in one maker (the Whip Scorpion's Siphon and the dock) are two
patterns, fuel against protection. The one-unit dock is the bodyguard, stronger as Ryan says
because it costs one turn or none; the bench. The kit as leaned: the carry (the map half of
the passive), the equipment slots (the combat half), three locked pieces (the mark, the
resupply, the dock) and two or three plain hardpoints, a die of eight or nine, the capstone's
complexity; the revive its own brief.

Ryan, 20 October, later: "I like Albatross, even though it doesn't technically fly. I'll take
other suggestions, though. Explain your point about the manifest slots. You're saying give them
a build rule that excludes weapons? Why, exactly? Dock all - It certainly can be only not-acted
allies that fly in. Makes sense. But when the carrier is gaining no additional mitigation and
luring all, is that not enough of a penalty? Regarding phased, I had been trying to find a way
to make it fair and not just 'invulnerable.' What I had landed on in my head was 'invulnerable
this round, and loses its next action.' Which could be this turn, or the next turn. But I
didn't like how that could make the invulnerability offset from the no-combat clause. The
alternative is obviously that a unit who has acted cannot be Phased, which is the exact
argument above. What are our three verbs that preclude including the revive?"

Claude, the same day. The slots: the equipment-only reading withdrawn. Ryan's quotation marks
meant slots whose entries are hand-overs, not a kind restriction, and a slot that refuses
weapons would break "any component in any slot" (the chassis file's first line) for one
machine; the gates the slots carry (the entry must show, once a piece a skirmish, the piece
leaving the carrier's die) bound a lent gun as well as a lent vent, and a flat gun on the
Sparrowhawk at die odds once a fight is a pairing for the runner to read, not a chase. The
dock: both prices stand, and they are one rule of Phased's: Phased is granted only to a unit
that has not acted this round, so it always costs the action it protects (Ryan's second form;
his first, invulnerable now and the next action lost, offsets the two halves, as he saw), and
the lure-all onto an unmitigated carrier is the second price, real against a swarm (it can die
there) and small against a boss, where the first price, the team's whole turn, is the one that
holds. Written on Phased, the rule fixes every grant of it (Aphelion's Sublimator too) and the
dock needs no clause of its own. The revive: the three verbs were the mark, the resupply and
the dock, beside the carry and the slots, five things to learn already; but a carrier recovers
what it launches, and the look's crane with its hook is the tell, so the resupply and the
revive fold into one locked piece, the recovery: an ally regains its shield to the maximum,
sheds all its heat and is cleansed; a wrecked ally instead returns with full shield and 10%
hull, once a skirmish for a wreck; one cooldown. It bends "damage sticks" (section 4) at 10%
hull, the capstone's privilege, the row carrying the exit (if a recovered wreck makes the wipe
a non-event in the runner, the wreck case moves to the commander's layer or goes). The kit
then: the carry and the slots as the passive's halves, three locked pieces (the mark, the
recovery, the dock), two or three plain hardpoints. Names: Albatross works (a lean is never an
exclusion, and the Mariner's bird carried as a burden is the price of a squad that bunches;
Kestrel's are raptors first); the maker's working animals as the alternatives: Camel (the ship
of the desert, carrying the squad over hard ground; lean among them), Mule (the army's pack
animal), Dray (the wainwright's own wagon).

Ryan, 20 October, later: "So the recovery is a cooldown for an alive ally, or a one-a-fight
for a scrapped one? I'm actually hesitant to give W and S a bird, because even Kestrel has non
raptor birds such as the puffin. What other names do you suggest, whether it's a flying animal,
insect, or a land-based animal, or anything?" Claude: yes, one piece, two cases: on a live ally
the resupply under its printed cooldown; on a wreck the recovery, which spends the cooldown and
the once-a-skirmish charge both, and the entry shows the rounds left and the charge spent;
ally only, the carrier never resupplying itself, so it stays a team piece. Names without a
bird, the reserved list checked (Albatross, Camel and Mule are on it, BattleTech's, so they
would need a recorded name_clash reason): Dromedary (the camel under its proper name, the ship
of the desert; the outback's camel trains carried the frontier; lean), Flying Fox (the one
flyer that is no bird: a fruit bat, an orchard pest, which carries its young in flight),
Bullock (the bullock dray, the frontier's heavy haul), Pack Mule (the army's pack animal,
clear where Mule is not), Pack Rat (the pest that carries, the maker's humour), Dray (the
wainwright's own wagon, no animal at all).

## Open for the session

Ryan, 20 October, later: "W&S has frontier animals, threats, and also insects. Dragonfly could
be one, similar to how hoverfly was proposed for the gunship. Anything in that spirit?"
Claude: Dragonfly is on the reserved list (BattleTech's, three entries), Mayfly and Cicada
too; clear, in that spirit: Damselfly (the dragonfly's slender cousin, four wings for four
rotors), Skimmer (a dragonfly family, and a deck that skims), Water Strider (a flat body held
on four legs spread wide, which crosses water: the deck on its four rotors and the carry in one
name; lean), Crane Fly (the gangly flyer whose legs dangle, and the look's crane with its hook
under the hull), Bumblebee (the heavy flyer that is not supposed to fly and carries its loads
home), Rhinoceros Beetle (the lifter, armoured, and it flies), Water Boatman (the bug that
rows: the ferry), Hoverfly (clear, if the gunship does not take it).

Ryan, 20 October, later: "Phased: what's your ruling? Recovery - still unsure. Give me pros and
cons of different options and potential holes or balance issues. I had an idea of introducing
an additional resource bar, with a slow recharge, that could power these big ultimate-level
abilities such as revive, repair, and dock. Let me know if that's too much. Obviously that
would be a three tiered passive, but maybe there's a way to fold it in if it seems worthwhile."

Claude's ruling on Phased: a unit that has not acted this round may be Phased, and one that
has cannot; Phased, it cannot attack nor be damaged by a blow until the round's end; ticks and
overheats still land (a docked machine still burns unless the dock cleanses it), and a blow
aimed at it is lost, never retargeted. One rule, on the status, for every grant.

The recovery's options. A, one die piece (the resupply on its cooldown; a wreck once a
skirkish): no new resource, the die's odds and the decided cooldown property gate it; against,
the property is not built, luck times an ultimate (fishing with the team's rerolls makes them
its resource, which cuts both ways), and a heat reset to zero on a cooldown hands the hottest
build a valve every few rounds, so heat stops biting on one machine (soften it to 30 shed, or
price it). B, Ryan's bar: a resource with a slow recharge powering the ultimates (repair, dock,
recovery): timing by decision rather than luck, fungible (which ultimate), the die kept
tactical (the mark, the slots), each ultimate priced once a charge so the heat-reset hole
closes, and it is the commander's layer in miniature, action economy nobody can stack;
against, a third bar on a phone HUD, a passive of three tiers against one idea, the bot, and
the scope if it is the commander's layer (section 8). Its hole: recharged within a fight it is
"once a skirmish" by another name; so battle-level, a point a map turn, three at most, repair
1, dock 2, recovery 3, usable while the carrier is fielded and alive, which paces the
ultimates across fights, the strategic piece Ryan asked for. C, the wreck recovered on the map
only (the crane lifts an adjacent wreck; the machine returns for the next fight at 10% hull):
visual and strategic, no in-fight swing; against, wrecks must persist as map markers, and a
10% machine dies again. D, no revive: simplest; the medevac fantasy lost. Common holes: a
surviving carrier reviving after a wipe keeps the fight going (the bar's cost caps it once a
battle); the heat reset; the dock's planned turn. Claude's lean: B as the commander's layer
with the carrier its vessel, the mobile command Ryan named first, if the scope is accepted;
else A with the heat reset softened.

Ryan, 20 October, later: "Sure, go with that definition of phased, except I think 'cannot act,
take damage, or be targeted' is cleaner. If an overheated unit phases, its allies cannot vent
it, and its heat will tick down by its cooling value, leaving the heat still a problem for next
turn, so I think that's fine. Also, the cannot be targeted clause shifts the intent lines as
intended, and the lure portion of the dock component isn't actually necessary. The commander
layer is the commander layer. The carrier is not the commander entering the battlefield. Their
abilities can and should be distinct. Regarding the overloaded passive, I think if I was to cut
something, it would actually be the component gifting. The more i think about playing it, the
more I realize how tedious it is both to play and balance. I think it needs to be cut. It's a
helicarrier, a mobile HQ, made for strategic and tactical support, and possible resupply. Let's
focus on that."

So (decided, 20 October): Phased is "cannot act, take damage or be targeted until the round's
end", granted only to a unit that has not acted this round (the vocabulary and the rules carry
it; a Phased machine cannot be vented and cools by its own cooling alone); the dock needs no
lure, since untargetable allies send the intents onto the carrier by themselves; the command
bar is not the commander's layer, whose abilities are distinct from the carrier's; the
equipment slots are cut. The kit after the cut (Claude, the same day): the passive is the carry
alone, one idea, the map half of the maker's identity brought to its end; the combat half is
the locked pieces, which is what a tier's "more locked pieces" is for: the mark (a foe the
carrier marks is in every ally's reach until its next action; no damage of its own, Flak's
kind; Exposed's shape is the Kestrel session's), the recovery (an ally's shield to its maximum,
its heat to zero and cleansed, on a printed cooldown; a wrecked ally instead returns with full
shield and 10% hull, once a battle), the dock (every ally that has not acted is Phased and
cleansed; the opening act or nothing by Phased's own rule); three or four hardpoints for its
own guns, a d6 or d7. The build hooks are the pieces' (every Direct gun through the mark, the
hot builds through the recovery, the planned turn through the dock) and the hardpoints'. The
bar stays on the bench as the carrier's own pacing device if the three cooldowns read as too
many clocks on one die: a point a round in the fight, three at most, the pieces spending it,
never the commander's.

What is still missing, after the cut (Claude, 20 October, on Ryan's "What else are we
missing?"; every item his to settle):

- **The recovery's decision.** As it stands its only decision is who; when is "when it is up",
  which is no decision (the README's taste). Two ways to give it one: the transfer, the carrier
  taking the heat it lifts onto its own gauge, so its own cooling is the team's budget and the
  piece needs no cooldown and reads as the tanker (against it: an ally vented directly, which
  Ryan marked as the less healthy way on 18 October, softened here because the heat still
  exists, on a machine that must cool it); or a cooldown long enough that spending it on the
  rank costs the boss round. Claude's lean: the transfer.
- **The mark against the front.** A reach grant does nothing on a front-rank foe, so the entry
  is dead there. Either the rider (the Kestrel session's Exposed, if it lands; a flat on-hit is
  Flak's) or Lure on the marked foe, which is built: the spotter draws the fire it directs, and
  the entry works on any foe. Claude's lean: Lure, the rider open.
- **The dock's real cost** is the allies' actions, not the carrier's hull, since Phased comes
  only before a unit acts: an emergency piece, right against a gathered blow or an alpha and
  dead most rounds. Three situational locked pieces on cooldowns make the carrier lean on the
  team's rerolls as the Cassowary does; the bench's bar is the answer if it reads as dead dice.
- **The pair with the artillery** is written in the artillery's brief (the recovery a full
  reload, a Flak shell by the rank); the carrier's side needs nothing new.
- **The tally.** The carrier's own spends deal no damage, as the Whip Scorpion's vents did: the
  to-do's Sponsorship line counts an ally's blow landed through the mark, or its hardpoint guns
  are its share and the rest is a lean.
- **Its footprint.** Assault, overflowing its hex (the look); the player's side has no massive
  class in the fight, so where the deck stands in the formation is the screens' question.
- **The bot** must value a reach grant and a round skipped (the dock) before the runner can read
  the carrier, so Ryan's play decides its feel first and the bands come late.

1. Ryan's calls: the name (Water Strider, Damselfly, Skimmer, Crane Fly, Bumblebee, Rhinoceros Beetle, Water Boatman; the working animals above); the kit after the cut (the carry alone as the passive, the three locked pieces on cooldowns, the bar benched);
   the recovery as one locked piece with the wreck case once a skirmish; the mark's rider and
   the Exposed question to the Kestrel session; the items above; then the
   numbers and the engine (the carry on the map, the lift and the nearest-standable set-down;
   the cooldown property; Phased with its rule; a reach grant on a foe, Lure beside it if the
   mark takes it; a wreck returning mid-fight).
2. Its shown text, which waits on what shown text calls a machine's die (a session of its own;
   Ryan, 13 October), if any of it names the die.

Ryan, 21 October: "Helicarrier - what if it pays for its abilities with its own hull? Is there
a build hook there? Or did I dismiss the component gifting too early as the build identity?"

Claude, the same day. Hull is the one number a battle never gives back (the rules: hull never
heals in a battle; the hangar repairs free), so a price in hull is a battle budget, not a
fight's: a recovery spent on the rank is plate the carrier does not have at the boss, which is
the strategic piece he asked for, paid in a gauge the player already reads, the bar's idea
without a third bar. What it fixes: the recovery's "when" (a budget question now, and the
heat-reset hole closes by price); the revive as a trade rather than a charge (a big slice of
the carrier to bring a wreck back at a tenth, capped by the carrier's own hull, the medevac that
cannibalises itself); the cooldowns go with it, so the carrier no longer waits on the cooldown
property; and the three pieces compete for one pool, since the dock concentrates the enemy on
the carrier and so drains the recoveries it could pay for later. Two forms. Hull alone, the
engine's Volatile with a number (past shield and armour, before the piece acts): simplest, a
pure strategic budget, nothing in a fight feeds it, and three Volatile chips on one die read as
the Arsenal's self-damaging kit (a Lean, never an exclusion, but a read). The stores, shield
first and hull when the shield is gone (the Corrupted bite's shape, a printed rule on the
carrier's pieces): the same budget in a fight is fed by every shield on the carrier, its own
shield pieces its ammunition, the Puffin's overshield a recovery for free, Armoured and Lure
elsewhere the plate's guard, so the carrier's hardpoints build its budget and the locked
pieces spend it, routes in and payoffs both; and it reads as resupply from the ship's stores,
not pain. Claude's lean: the stores, priced on the recovery and the revive, the mark free (a
spotter does not bleed), the dock priced by the exposure it already costs. Holes for his
call: no floor, so a carrier may spend itself dead on its own turn (Volatile's precedent) and
a low carrier is a carrier that cannot support (Hubris's shape, section 7's bench; the die
shows the cost, so it is the player's); the boss dump, a full pool saved all battle and spent in
one fight, capped by the die (one spend an entry a round) and the pool, measured rather than
guarded; the Puffin loop (overshield, spend, overshield) priced in the Puffin's own die and the
carrier's spend; a d4 of shields on the carrier, which the Puffin row refuses as a shield-bot,
held off by every shield on itself being an action before the spend it feeds; the bot weighs
hull spent as it weighs Volatile. On the gifting: not dismissed too early. Its hook ran one way,
the carrier feeding allies with nothing feeding the carrier, its hangar form was his own "not
tenable" and its fight form the most UI of any design here; the pool gives the same "my build
shapes what I give" in a bar and a die that exist, and keeps the hangar question (shields and
plate against guns on the carrier) small. If a hangar-side hook is wanted later, the cheapest
form is one bay slot, benched, never the two.

Ryan, 21 October, later: "Marks rider is solved in the Kestrel session. I have a better shape.
It has a third resource bar. It fills slowly, every time its die rolls (kestrels shape - it's a
flyer), it can store charges, up to max. It's locked components can consume a charge from the
resource to empower themselves. The dock: goes from giving all allies barrier on a cooldown to
phasing them all on a cooldown. The mark: goes from marking an enemy to marking and suppressing
an enemy. The resupply: goes from a basic shield+cool to a full shield+cool. Maybe a fourth
locked piece that helps it reroll: gives the team a reroll, goes to letting an ally act again.
That's similar to the Kestrel capital ship, but they can overlap if both make sense. 3-4 open
hardpoints."

So the shape (adopted; the hull price above goes to the bench, one line): the carry stays the
passive's map half; its fight half is the charge, a bar of its own that gains a charge each
time its die rolls, stored up to a cap, the Prairie Dog's two-clause shape; every locked piece
has a plain form, spent any time, and a charged form that consumes a charge: the dock (the
allies protected, or every ally that has not acted Phased), the mark (the Kestrel session's
rider, or that and Suppressed), the resupply (a small shield and cooling, or the full reset),
and perhaps a fourth, the rally (a team reroll, or an ally acts again); three or four
hardpoints. A plain form on every piece means no entry is ever dead, which closes the dead-dice
hole above; the decision each round is spend the charge now or bank it, and which piece gets
it. The act-again form is the action-economy row's tempo lent, ranked last there, and it
passes the row's own price: a second action paid in a banked resource (the charge) and the
carrier's action, never free; its engine is the gun platform's (a die rolled again and acting
again), so the overlap Ryan allows saves engine work rather than costing it.

Claude's holes, the same day, each his to settle:

- **What fills it.** "Every time its die rolls" counts the round's roll and every reroll spent
  on it, so the rate is one a round plus the team's rerolls spent on the carrier (up to three
  more), and a Rapid piece in its hardpoints turns its free reroll into a charge: not slow, and
  the gun platform's gimmick exactly (the team's rerolls as fuel). Three forms: the opening roll
  alone (slow, a charge a round, no decision to make); every roll, with a small cap, so the
  team's rerolls are the fuel and the decision (a reroll on the carrier is a charge, one on the
  Sparrowhawk is damage), shared with Kestrel by his leave; every roll but Rapid's free one,
  so no chain farms it. Claude's lean: the third, cap three.
- **The dock's plain form.** A Barrier on every ally breaks a Decided row (section 5: "A
  Barrier is never granted to every ally at once: four blows negated for one spend is the
  exploit the shield rule removed"), and it would not be the weaker form: Barrier-all leaves
  the allies their actions where Phased costs them, so a player would often prefer the plain
  spend. Plain forms that keep the row and sit under Phased: Armoured to every ally until the
  round's end (the Shoring Jack's kind, soft, the swarm's answer), or a Barrier on one ally
  (the Blast Door's), or a small shield on all. Claude's lean: Armoured-all.
- **Per fight or per battle.** Charges that reset each fight (heat's shape) bring the
  ultimates online from round three or so, which paces them and keeps the opening act for the
  dock honest; charges carried between fights are the strategic save for the boss and the
  bar's own version of section 12's open question on heat between fights. Claude's lean: per
  fight, and the carry-over decided with heat's.
- **The rally feeding the bar.** Spend the rally's plain form, reroll the carrier with the
  reroll it gave, gain a charge: one action to one charge and a fresh entry, a loop by design
  or a leak. Either the rally's own reroll never counts, or it is the intended combo in the
  maker's spirit (the Cassowary's dial). Claude's lean: it counts, and the cap holds it.
- **Double gates.** A charge and a cooldown on the dock is two clocks on one piece; the charge
  is the gate, so the cooldown can go, which takes the unbuilt cooldown property off this
  machine's engine list, and the charged mark's Suppress has Numbed for its cooldown as every
  stun does (the stun row: a charge is a price paid, so the stun is gated).
- **Three bars on the maker.** Wainwright & Sutler would carry Spun Up's pips, the artillery's
  magazine and the carrier's charges: three banked resources, each shown on its machine, a
  phone read to judge, not a rule (the action-economy row lists more resources than makers).
- The engine: the charge (a bar that gains on every roll, a trigger the engine lacks), a spend
  that consumes a charge for its charged effects (a face property), Phased with its rule, the
  carry, the mark's rider (the Kestrel session's), Suppress (built), act again (the gun
  platform's), the resupply's reset.

Ryan, 21 October, later: "Note that I meant it takes MANY rerolls to gain a charge. That's why I
said slow. Like I dunno, 10 per charge. Each time it rolls a sliver of a charge is granted,
since these are supposed to be 'ultimate tier.' We could also say, 'any time a die rolls' to
play up the team player aspect, or add 'whenever it kills something' to force it to engage in
the fight. Point is, you have to work for it. I think team shield is healthier than team
armour, isn't it? Since team shield is allowed now, and nothing currently does it? I think per
fight makes sense in terms of not making the player feel like they need to farm charges, but
per battle seems easier to tune. We can start per fight. Charge and cooldown on the dock was
because I thought it was too strong anyway. We can try without if the effect is softened."

So (his calls): the bar fills by slivers, about ten rolls a charge (a placeholder), so a charge
is a fight's work and the Rapid leak above is nothing (a chain is a quarter of a charge); per
fight, starting empty like heat, the carry-over section 12's heat question; the dock's plain
form a team shield; the dock without its cooldown if the charged form is softened. Claude's
reading of the three: the team shield is the healthier plain form, since under the honest
shield rule it is priced by its number, bounded by each ally's shield maximum, answered by
breach and the big blow, and the exploit the Barrier row names was the old whole block, not
the number; Armoured-all is the dearest stat handed to four machines at once and, repeated
each round on a team of heavies, the wall the Armoured row guards against, while a team shield
is a product nobody makes (the identity test's "new product"). On the fill's source: its own
rolls, about ten a charge, is the simplest count and feeds on nothing; any die's rolls, about
thirty a charge for the same pace, makes every team reroll, the Clydesdale's free one and the
gun platform's passes the carrier's fuel, two routes in from other makers and the team-player
read he wants; a kill by its own guns worth several rolls is the engagement hook on top of
either. Claude's lean: any die at about thirty, a kill by it worth five, every number a
placeholder; the bar a filling gauge on its own machine, not pips. On softening the charged
dock: it is already paid three times, a fight's charge, every docked ally's action and the
whole enemy turn on the carrier, so no cooldown and no further softening until the runner and
play read it; if it reads too strong the lever is its price (two charges), a price rather than
a clock, as the stun row prices a stun. The charged mark's Suppress is gated by the charge
and clocked by Numbed. Left for his call: the fill's source, the name, then the go (a row,
planned content, the brief retired).

Ryan, 21 October, later: "Agree with everything, could use help with naming." So decided: any
die's roll feeds the bar, about thirty a charge, a kill by its own guns worth five, per fight
from empty; the dock's plain form a team shield, its charged form Phased on every ally that
has not acted, no cooldown; the mark's charged form adds Suppressed; the resupply's a full
reset; the rally's an ally's second action; every number a placeholder.

Names (Claude, 21 October, checked against `content/reserved_names.json`; his pick):

- **The chassis.** Possum: the brushtail carries its young on its back (the carry) and plays
  possum (the dock), the frontier pest; borderline, since BattleTech has an Opossum, though the
  Australian possum is another animal and the word a near-coincidence, his case-by-case call.
  Bellwether: the sheep the flock follows, the working animal whose job is the mobile command;
  clear. Crane Fly: the gangly flyer whose legs dangle, and the crane under the hull; clear.
  Water Strider: the deck on four legs that crosses water, the lean until now (Strider alone is
  BattleTech's class word; the pair reads as the bug). Mud Dauber: the wasp that builds the
  nest; clear. Bumblebee, Skimmer, Darner, Jacana (a bird that carries its chicks under its
  wings; he is wary of birds here): clear.
- **The designation.** Pattern 20 Field Headquarters, or Pattern 20 Aerial Tender.
- **The passive** (the carry and the bar): Muster Deck. **The bar**: Muster, a charge a muster,
  the pieces "spend a muster".
- **The dock**: Mooring Screens (the team shield; charged, the hangar shutters close on the
  squad), or Hangar Shutters.
- **The mark**: Spotting Flare (the observer's flare that marks; charged, it blinds), or
  Signal Lamp.
- **The resupply**: Sutler's Hoist (the army's provisioner, the maker's own word, a job and a
  wink; the bible allows a maker naming itself short of advertising), or Tender Winch.
- **The rally**: Reveille Horn (the bugle that wakes the camp: a reroll, or an ally up and
  acting again), or Bugle Call.

Ryan, 21 October, the go: "Swallowtail? Everything else I agree with your leans." Swallowtail
is clear on the reserved list; so the Swallowtail, Pattern 20 Field Headquarters, the Muster
Deck and its Muster, the Mooring Screens, the Spotting Flare, the Sutler's Hoist and the
Reveille Horn, three hardpoints. The row, the planned content and this brief's retirement
follow in the go's commit.

## What the session hands back

A proposal in chat; on Ryan's go, content planned (a spend by another machine is engine work,
and the bot must choose the spender), and this brief retired.

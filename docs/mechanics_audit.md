# Mechanics audit, 25 October

Ryan's ask, after the Flak fix (Flak added nothing to a blow lowered to 0): a sweep of the
game's mechanics for anything that doesn't add up, doesn't seem right, or doesn't match the
records. Read from the code (`sim/`), the content and the records (`docs/rules.md`, the
bible); Godot could not run in the session that wrote this, so every finding was traced
through the code by hand and is cited by line, never measured (one, 33, was reproduced with a
model of Godot's random generator). Claude read the skirmish engine; three agents read the
map, the campaign and saves, and the content against the engine, and every finding of theirs
was checked against the code before it landed here. The Flak fix itself is left out (a note
on its follow-ons closes the skirmish section).

How to read it. Each finding carries a kind:

- **Bug**: the code does something the records don't say, and today's content reaches it.
- **Latent**: the same, but no content reaches it yet (it bites when content lands).
- **Text**: shown text or the records say something the engine doesn't do.
- **Question**: the code does what the records say, but it defeats the mechanic's own purpose,
  the Flak kind of problem. Ryan's call; each carries Claude's lean, never a decision.

Nothing here is decided but what Ryan settled. It retires once its findings are fixed, struck
or turned into rows and tasks.

Ryan's triage, 25 October: fixed 1, 2, 6 with 7, 22, 24, 31, 33 and 35; the Flak fix's follow-ons
were done already on `ccr-170f6d81-465jnr` (Flak on a damaging weapon's blow of 0, and its hit
spending a Shock, cashing Cryo and laying Vitriol whatever it dealt), merged under these fixes;
his call next on 3, 4, 5, 23 (on hold), 25 and 32. The rest waits on his read. Line numbers
are as at `a8a0e43`. `claude/playtesting-issues-08mnqj` (his playtest list, the same day) plans
moves and takes UNDO back last-first to the turn's start or the last fight, which closes 23, 24
and 25 by construction once it lands.

Start here, the ones that change play most:
1. A Gel's halves and a Ghost's summons count as their pack: a withdrawal or a lost fight
   walks it on larger, and scores its kills as none (1).
2. A resumed battle spawns its packs with no ring, move or hunt (22), and a resumed fight
   never splits or summons (31).
3. A domain can field two finals at once and refight a hero already beaten (32).
4. The runner's "random" start isn't (the Armadillo starts every run it's offered), and the
   tender predicts the first rifts (33).
5. The Spin-Up chains into itself for free, against the premise of its limiter exemption (3).
6. A rally's Kindled is multiplied by the move's factor: +0 on the Bomb's Flare Up, +6 on Holy
   (4).
7. The Flak kind: a crack or a silence takes Volatile's price and leaves the number (5), the
   Ward answers none of the Peak's big scorch (6), and overshield outlives the fight (2).
8. The carry's undo: refused after two pieces (23), able to stack two machines (24) and to
   take back a rider that has fought (25).

## The skirmish

### 1. Fixed 25 October. Bug: a Gel's split and a Ghost's summons join their pack, so a pack can grow
`Skirmish._split` (sim/skirmish.gd:966) and the summon special (sim/skirmish.gd:2196) give
the new foes the caller's `pack_id`; `survivors_for` (sim/skirmish.gd:250) counts every foe
of that pack id on the field or waiting; `Battlefield.apply_skirmish_result` sets the pack's
strength to that count (sim/battlefield.gd:587); and `ContentDB.foes_for` rebuilds the pack
as strength copies of its own foe (sim/content_db.gd:525). So after a withdrawal or a lost
fight:
- a Gel pack of 4 with 2 Gels killed leaves 2 Gels and 4 Half-Gels, and walks on as **6
  Gels**;
- a Ghost pack of 2 whose Raise called up 2 Revenants walks on as **4 Ghosts**.

The rules say a pack is one foe type times a strength and packs never escalate
(docs/rules.md:620, :644). The same count undercounts kills, where the bible says "a kill is
a kill: every foe killed pays salvage however its fight ends": `kills_for` is strength less
survivors, floored at 0 (sim/skirmish.gd:290), so the two dead Gels above score 0 kills and
0 salvage, and a full clear of a 4-Gel pack scores 4 for its 12 kills. Boss units are safe
(their escort counts `escorts` only); a foe in parts would grow its pack the same way (its
parts and their regrowth take the core's pack id, sim/content_db.gd:661,
sim/skirmish.gd:3419), latent while no content has parts. The map bot never withdraws, but a
fight it loses while other machines stand on the map leaves the pack grown the same way, so
`docs/campaign_run.md` can carry it. Fix: count a pack's survivors by its own foe type (a
risen one included), and its kills from the foes that fell.

### 2. Fixed 25 October. Bug: Overshield's excess outlives a fight that ends mid-turn or by withdrawal
The excess is trimmed only in `end_round` (`_trim_overshield`, sim/skirmish.gd:1353). A
fight won mid-turn ends at once (`_check_outcome`), and a withdrawal skips the round's end
(sim/skirmish.gd:1698), so neither trims; `finish_skirmish` doesn't clamp
(sim/battle.gd:699), and `Unit.recharge_shield` keeps a shield already past its maximum
(sim/unit.gd:264). The Puffin's Backwash Ionizer ("until round end", its codex) on an ally at
full shield, then the last kill that turn: the ally walks the map over its maximum (3, plus the
Slipstream's point for every 2 heat the ally carries: 8 at 10 heat) and opens the next fight
with it, through that fight's first enemy turn. Overshield then a withdrawal keeps it on
purpose. Fix: trim at `_finish`.

### 3. Ryan's call (its intent pulled, 25 October). Question: the Spin-Up can chain into itself for free
The rules say both "its Spin-Up spins the whole die, the entry showing included"
(docs/rules.md:99) and that it needs no limiter because "the cylinder cannot chain it into
itself" (docs/rules.md:217); the bible says both in one sentence. The first is what runs, and
a test pins it ("it lands anywhere, itself included", tests/test_skirmish.gd:5544): `_act_again` makes a spin a true roll over every entry, itself included, before
it asks whether the die steps (sim/skirmish.gd:2270). With cooldown 0 and no heat, a
Spin-Up that lands on itself (one in six on the Cassowary's six entries) goes again, a Spun
Up stack a time, without end. The validator exempts it from the limiter rule on the stepping
die alone (`_locked_on_stepping_die`, sim/content_db.gd:936), and the bible's own exit says
"a stepping-die piece that ever makes a free chain gets a limiter of its own". Small in
expectation (a fifth of a spin more a spend), unbounded in principle. Question for Ryan: a
limiter (a heat, or the spin never landing on itself), or keep the spin and strike the
exemption's premise.

### 4. Ryan's call (Rally explained, 25 October). Bug: a rally's Kindled is multiplied by the move's factor
`Foe.damage_of` adds Kindled to the base attack before the move's factor
(sim/foe.gd:176), where Kindled says "hits {value} harder" (the chip, the rally's text,
docs/rules.md:406) and the bible gives it the job of "lifting a small blow over the plate".
With the Magma Elemental's Stoke the Forge (+2): the Bomb's Flare Up (0.34) goes 3 to 3, **+0**;
the Sandworm's Quake and the Martial Artist's Hundred Fists +1; the Lancer's Dragon Dive (1.5)
+3; the Black Mage's Flare and the Augur's Omen (2.0) +4; the Cleric's Holy (3.0) **+6**,
which the finale can field beside a standing Magma Elemental. The intent number is right (it
reads `damage_of`); the promise isn't. Fix: add the rally after the factor, as the Kite's
double adds the buffs once after the printed number.

### 5. Ryan's call (25 October: Cracked gone? Silence on buffs alone?). Question: a cracked or silenced Volatile piece loses its price and keeps its number
Volatile is a keyword, and a crack clears keywords (`Face.crack`, sim/face.gd:630;
`volatile_cost` reads the keyword, sim/skirmish.gd:489), so a crack takes the hull price
away and leaves the number. The Oblation Mantle (shield 10, Volatile 3) and the Entropy
Condenser (vent 10, Volatile 3, the capstone "paid in hull") are strictly better cracked; the
Umbra Inducer loses its Suppress with it, so it nets out. Silence does the same by the
rules' own words ("a Volatile bites nothing", docs/rules.md:363), so a foe's silence frees
them too (no foe carries silence yet). An injury and the enemy's answer should never be an
upgrade. Lean: a price outlives a crack and a silence (as a printed cooldown already does,
docs/rules.md:225), Volatile read as a price rather than a keyword.

What a crack takes is unsettled besides: the vocabulary's Cracked component says it "loses its
keywords and unique effects" (content/vocabulary.json, `cracked_component`), where the rules
(docs/rules.md:469) and the engine (`Face.crack`) take the keywords alone, so a cracked
Afterburner Cannon still vents all and a cracked Pinion Driver still resets. One of the two
moves, and the answer decides whether a crack should take a printed price too.

### 6. Fixed 25 October (Ryan: "Should stop all riders, even from non-damaging attacks"). Question: the Ward turns away no special, and the Peak's scorch is mostly specials
The Ward stops riders on blows only (sim/skirmish.gd:1528), plus the silence and purge
specials (sim/skirmish.gd:2225, :2231), as the rules say (docs/rules.md:338, :514). The bible
gives it the job of answering "the Waste's breach and the Peak's scorch". The Peak's heaviest
heat is specials: Eruption, Fira and Pyroclasm (Scorched 4 on every machine), the Drake's
Stoke (Burning 4), with the Summoner's Diamond Dust (Corrupted) and the Cockatrice's Stone
(Disabled) alike; the Ward answers only the 2-stack scorch on blows (the Bomb, the
Salamander, the Drake's Breath, the Black Mage's Fire). Lean: a Ward turns away the debuff
specials on its machine as it does the riders.

### 7. Fixed 25 October, with 6. Bug: specials on every machine reach a Phased one
A blow at every machine skips a Phased machine (sim/skirmish.gd:1456), but the scorch-all and
corrupt-all specials walk `live_mechs()` (sim/skirmish.gd:2237, :2243), so a machine the
Mooring Screens Phased still takes Eruption's Scorched and Diamond Dust's Corrupted. Phased
"cannot be targeted" (docs/rules.md:312). Fix: skip Phased there too.

### 8. Bug: a sprayed spend's Primed burn all lands on the first foe
A Primed machine's Burning is summed over the strikes and laid on `target` after the loop
(sim/skirmish.gd:1925), so a Skua's Flechette Pod whose strikes fell on three foes puts every
stack on the first, a corpse when the first strike killed it. Primed lays its stacks "on its
target" (docs/rules.md:311), each blow's own. An ally's Aurora Lattice reaches the Skua today.
Fix: lay it on each strike's own foe. (A Spread's neighbours get none, which the rules allow
and the status's "every blow it lands" leaves open.)

### 9. Text: conditions on the target are judged on the aimed foe for the whole area
The attacker's modifiers are read once a strike against the foe aimed at
(sim/skirmish.gd:1817) and the same blow goes to every foe it reaches. So the Susceptibility
Tensor ("its blows deal 1 more to a foe carrying any status") gives a Spread's clean
neighbours the point when the aimed foe carries a status, and none to marked neighbours when
it doesn't. The funnel-web's Ambush, by contrast, judges "each foe reached alone"
(docs/rules.md:558). Either the Tensor's text says "aimed at a foe carrying any status" (the
Ram Frame's wording), or a target condition is read per foe as Ambush's is.

### 10. Latent: a last act hits Phased machines and reads the wrong blow
`_last_act` strikes every live machine for a blow at all (sim/skirmish.gd:3437) and its pick
without asking whether it is Phased (:3442), where the enemy's turn skips them. `_damage_mech`
returns early on a Phased machine without recording a blow (sim/skirmish.gd:3107), and
`_strike` then reads the last recorded blow anyway (sim/skirmish.gd:1519): a stale one from
the last enemy turn, or out of range in a fight's first round; and its riders land on the
Phased machine. No foe carries a last act today.

### 11. Latent: a Silence switches off Phased, Ward, Barrier and the Armadillo's seal
Silenced suppresses every modifier tagged `buff` (sim/effects.gd:265), and Phased, Ward,
Barrier and Sealed all carry the tag. A silenced ally the charged Mooring Screens reach still
stands its die down (`_phase`, sim/skirmish.gd:2376) but takes blows as if unphased, and the
foes that re-pick may pick it again. A silenced Armadillo loses its +3 armour and also its
seal's costs (its cooling runs, no 3 heat a turn), since both read `is_sealed`. All by the
letter ("its buffs count for nothing"); the Phased case costs an action for nothing. No foe
carries silence yet.

### 12. Latent: the die over a Guarded core shows the full number
`shown_number` folds in a foe's flat damage-taken adds only (sim/skirmish.gd:365), so the
Guarded core's ×0 is never shown, where the screen's own comment expects "the zero its die
shows" (game/skirmish/skirmish_screen.gd:1128). No boss in parts in content yet.

### 13. Bug, rare: the enemy's turn ends early when no machine is targetable
`_foe_turn` returns false when its re-pick finds no machine (sim/skirmish.gd:1433), and the
turn breaks there (:1408): every foe after it skips its statuses' tick (Burning, Numbed, an
Armoured from its brace that should drop), its web, its countdown, and its specials that act
on nobody. Today's content reaches it: the charged Mooring Screens Phase every ally, the
foes re-pick the Swallowtail, and once it is wrecked mid-turn every foe after the blow that
wrecked it stops. Fix: go on to the next foe; only blows need a target.

### 14. Text: "below half" fires at exactly half
`below_half` is `hp * 2 <= hp_max` (sim/skirmish.gd:907), the codex's "when below half"
(sim/foe.gd:66). For rank and file it's a whole step: the Bomb (4 HP) can self-destruct at 2,
not only at 1. One or the other moves. Its neighbour "when hurt" (`missing_hull`,
sim/skirmish.gd:909) needs the move's own value missing, which is right for a regrow and
wrong for a brace: the Sandworm's Burrow (armour 3) reads 3 HP lost as its threshold.

### 15. Text: the Drake's Stoke picks at random
"The Drake's Stoke sets the hottest machine burning" (docs/rules.md:460), but neither the
Drake nor Stoke carries the heat aim since the 24 October random baseline, so it burns a
machine at random. The rules line is stale (or Stoke takes `aim: heat`, as the Black Mage's
Fire wears it).

### 16. Text: the Grievance Reliquary overcharges on more than blows
"Taking hull damage Overcharges it, a stack a blow." Its trigger is any hull lost (a bite, a
Volatile spend, the Tithe Coupling's price, an overheat), so a Tithe Coupling beside it
Overcharges every spend. Either the text says "each time it loses hull", or the effect reads
blows only.

### 17. Bug: Siphon heat fires no heat-gain passive
The Siphon's heat a blow is added straight to the gauge (sim/skirmish.gd:3151) rather than
through `_add_heat`, so an on-heat-gain passive (the Boundary-layer Bleed's shield) never
answers it. Every other heat in the fight goes through `_add_heat`.

### 18. Text: the Stingray deepens most stacks it lays on itself, not all
"Every stack this machine applies, to a foe, an ally or itself, is one deeper for every 5
heat." A brace's Armoured, the Stoker's Burning on its own firer and a passive's or a
module's stacks (the Phase Conjugator's Armoured on an ally, the Grievance Reliquary's
Overcharged) don't pass through `_stacks_from` (sim/skirmish.gd:1279, :1287; `Effects.fire`).
The Stoker is a hardpoint piece, so a Stingray at 10 heat can carry it and burns itself 1, not
3.

### 19. Bug, small: the Cottonmouth's Spread carries a consumer's bonus to the neighbours
A consumer's point a stack is added to the roll (sim/skirmish.gd:1809), and the roll reaches
every foe the blow does. "One blow on one foe (no strikes past one, no area)"
(docs/rules.md:266), and the validator holds the authored face to it, but the Cottonmouth's
drum grants Spread at the front and Penetrate at the back, so its Backdraft Charge pays the
burning target's stacks to its neighbours too (Burning 4: 8 on all three). A Coriolis
Accelerator through the drum carries the aimed foe's missing-HP bonus to the area the same way
(item 9's kind).

### 20. Question: the winning turn is free of heat
END TURN's costs (Burning's tick, the overheat, the seal's heat) never land on the turn a
fight is won, since the fight ends the moment it is decided (sim/skirmish.gd:1340) and heat
starts the next fight at zero; costs paid at the spend (Volatile, a corrupted bite, the
Tithe) land as ever. So the last turn of every won fight is an overheat without a price,
and a machine can run any heat it likes on its killing turn. Lean: leave it (it is the
roguelike's last-turn freedom, and the stakes are elsewhere), but the bot and the runner
should know it.

### 21. Smaller ones
- The Zombie Knight may announce Reraise while it already carries Getting Back Up: nothing
  stops a readied foe from readying itself again (sim/skirmish.gd:2177), so it wastes its move.
  The Cleric's ally form has `ally_unready`; the self form has no such condition.
- Retaliate shocks a striker whose blow came to nothing: `_blow` calls a blow of 0 not
  blocked (sim/skirmish.gd:3180), so a blow a damage-taken effect brought to 0 (the Prairie
  Dog's −1 on a blow of 1) still reads as a strike on bare hull.
- On a withdrawal under the Prairie Dog's screen, a special whose meaningless pick is a
  screened machine is lost whole (sim/skirmish.gd:1460), Eruption included, while one whose
  pick is unscreened scorches the screened machines too.
- A Shocked is spent, and Cryo cashed, by a blow that armour then takes to nothing: the test is
  the attacker's number before the foe's armour (sim/skirmish.gd:1859, :1900). A Shocked
  Sandworm under Burrow (armour 4) struck for 1 takes 0 and loses the shock. The rules say
  "the next team blow that deals it damage" (docs/rules.md:375); the status's own text ("the
  next blow it takes") matches the engine.
- The Baboon's "a status other than Paradox" and the Susceptibility Tensor's "any status" read
  the team's debuffs only (`FOE_STATUSES`, sim/effects.gd:331), never a foe's own Armoured,
  Kindled or Getting Back Up, though those show as chips too.

### The Flak fix's follow-ons (done on `ccr-170f6d81-465jnr`, 25 October)
The same "a blow of nothing stays nothing" gate lives in four more places, which a fix in
`Effects.damage_taken` alone leaves behind: the die's number (`shown_number`,
sim/skirmish.gd:364), the bot's (sim/policy.gd:1005), and the strike's own reads of "did it
deal anything", on the attacker's number before Flak: spending a Shocked (sim/skirmish.gd:1859,
:2605), laying a passive's stacks (:1864) and cashing Cryo (:1900). Once Flak lifts a 0 to a
1, whether that strike spends the shock, lays Vitriol and cashes Cryo wants one answer. And
`damage_taken`'s early return serves the machines too (sim/skirmish.gd:599, :3109): moved for
the foes alone it changes nothing there, but moved for both it turns a foe's 0 on an
Exotic-matter Shell into 2 and spends a Barrier on it.

## The battle map

The pack-growth bug (1 above) is the map's worst too: the map is where the grown pack walks
on.

### 22. Fixed 25 October. Bug: a resumed battle's Rift Pressure spawns come out undressed
`field.foe_profiles` is filled once, in `Battle.setup` (sim/battle.gd:123); a battle loaded
from its save never fills it (`SaveGame._field_from`, sim/save.gd:197), so `dress_pack`
(sim/battlefield.gd:69) finds nothing for a spawn and leaves the Unit's defaults: ring 1, move
20, a pusher. After any RESUME (the harness's, or the campaign's battle inside its run), every
pack Rift Pressure spawns walks wrong: the hunters (the Goblins, Dire Wolves, Needlers,
Revenants and Bombs, every domain's first spawn among them) push for the gate instead, the Dire
Wolves, Needlers and Bombs move 20 instead of 30, and the Mandragora, Cockatrice, Ghost and
Drake ring 1 instead of 3. Packs already on the field are saved with their numbers,
so the fault shows only later. Fix: fill the profiles on load (the content is to hand).

### 23. On hold (Ryan, 25 October: whether a move comes in pieces at all). Bug: UNDO MOVE goes dark after a carry in two pieces
Each piece of a carrier's move logs every rider again (sim/battle.gd:327), and `can_undo`
asks every record's rider to stand where that record set it down (sim/battle.gd:344). After a
second piece the first record's landing is stale, so a Swallowtail that moved a hex, then
another, with a rider beside it, can undo neither, though nobody has fought or moved alone.
`undo_move` itself would replay the records last-first correctly; only the check is wrong.

### 24. Fixed 25 October. Bug, rare: undoing a carry can stack two machines on one hex
`can_undo` checks only the carrier's own first hex (sim/battle.gd:349); `undo_move` puts each
rider back where it rode from without asking whether that hex is still free
(sim/battle.gd:373). Carry a rider off, move another machine into the hex it left, undo the
carrier: two machines share the hex ("One unit to a hex", docs/rules.md:595).

### 25. Ryan's call (25 October: riding spent is fine; the undo after a rider's fight is the question). Question: a carry can be undone after its rider has fought
A fight clears the move records of the machines in it only (sim/battle.gd:705), so a carrier
that stayed out keeps its undo while the rider it set down fights. Carry a machine into range,
fight with it, then UNDO the carrier: the spent rider goes back behind the line and the
carrier gets its whole move back to carry the others. "UNDO MOVE restores a machine until it
fights" (docs/rules.md:610), and the bible's Swallowtail row wants "reach and never a reset".
Lean: a carrier's undo closes once any rider it set down has fought, as the rider's own would.

### 26. Question: a boss killed in a fight that then wipes the team loses the battle
A fight goes on past the last commander's fall while its escort stands, and when it ends the
battle asks "every machine wrecked" before "the boss gone" (sim/battle.gd:729), so a team that
kills the final's hero and is then wrecked by its escort (or its own overheat) reads as
WRECKED: the wipe's phases on the gate, the rift open, no Favour, the final not won. "Its
death wins the battle" (docs/rules.md:638), and the end conditions carry no order
(docs/rules.md:645). Withdrawing right after the kill would have won. The same when the hero
burns to death at the start of the enemy's turn and its escort wipes the team in it; at the
finale the order can lose the run after the whole party has fallen. Ryan's precedence to set;
lean: the boss's death wins, as the rule reads.

### 27. Text: flyers hold nothing, and the rules never say so
A pack walks under a flyer (`can_block()` is false for a flyer, sim/unit.gd:217;
sim/battlefield.gd:333) and is only refused a stop on one. "They walk round machines and other
packs" (docs/rules.md:622) and "holding every pack takes three machines" (the bible) read as
if every machine held ground; three flyers across a ford stop nothing. The rules line wants
"grounded machines".

### 28. Text: the gate's codex is wrong twice
"A pack that reaches the apron strikes it for a third of its strength each phase, at least
ten ... Machines may stand on it" (game/battle/battle_screen.gd:716). The strike is strength
times 10 divided by 3, at least 10 (sim/battlefield.gd:466; a pack of 6 strikes 20, not 10),
and no machine may stand on a structure (`can_stand`, sim/battlefield.gd:128). The text
predates the stock pass's single digits.

### 29. Text: the codex's map claims for the Thief and the Dire Wolf
- The Thief "goes for the slowest machine you have": a hero only ever commands the boss unit,
  which never hunts and patrols a hex a turn whatever its move (sim/battlefield.gd:74, :373),
  so its `hunt`, `hunts` and `movespeed` are dead data, and in the fight it aims at the armed.
  (Its "when it is hurt it leaves" waits on Flee, still planned.)
- The Dire Wolf is "faster than anything you own but the cars": it moves 30, and ten machines
  that are no car move 40 or 50 (the Kite, the Buzzard, the Stingray, the Puffin, the
  Cassowary, the Cottonmouth, the Lammergeier, the Skua, the Needletail, the Storm Petrel).

### 30. Text, small ones
- The boss "patrols its ring of the rift (ring 2; a final's back-rank hero ring 3)"
  (docs/rules.md:637): the patrol is always within 2 (`BOSS_ZONE`, sim/battlefield.gd:280);
  3 is the back-rank hero's ring for joining fights. The line runs the two together.
- A Rift Pressure spawn is named by its content id (sim/battlefield.gd:559: "wolf pack",
  "zombie_knight pack"), where the setup's packs take the content name ("dire wolf pack",
  sim/battle.gd:159).
- The terrain tap names crags "mountain" (sim/battle_map.gd:12); the rules say crags.
- The code and the validator take a fifth hunting caveat, "fastest"; the rules list four.

## The campaign and the saves

Two of the battle's bugs are the campaign's too: the resumed battle's spawns (22) and the boss
killed before a wipe (26).

### 31. Fixed 25 October. Bug: a fight resumed from a save never splits, summons or regrows
Only a fresh fight is given the content's foe factory (`_build_skirmish`, sim/battle.gd:682);
the save's rebuild (`SaveGame._skirmish_build`, sim/save.gd:420) never sets it, and only the
planner's clone copies it (sim/save.gd:413). `_split`, the summon special and `_regrow_parts`
all do nothing without it (sim/skirmish.gd:958, :2192, :3407). Put the phone down mid-fight
against Gels and pick it up: every Gel killed after that leaves no Half-Gels, and a Ghost's
Raise calls nothing ("A dead Gel splits into two Half-Gels", docs/rules.md:528). The resume test
fights Goblins, which neither split nor summon. Fix: set the factory on load.

### 32. Ryan's call (25 October: a beaten domain's other rifts close). Bug: a domain can hold two finals at once, and the second refights a beaten hero
Whether a rift is a final is decided as it opens (`_roll_rift`, sim/campaign.gd:601: three of
the lead's bosses beaten and its final not won), and `start_battle` takes the final's branch
without asking again (sim/campaign.gd:316). Every rift of that lead opened before its final is
won is a final too, so after one is won the other still fields the hero the domain was thinned
of, and pays a full win. "Three bosses of one domain beaten make its next rift a final ... a won
final thins the domain" (docs/rules.md:688). How often (a model of the turn loop, not the
game's stream, so an estimate): two finals of one domain open at once in about 45% of runs
under the runner's front choice, a thinned hero refought in about 25%; 1 to 2% for a player who
takes finals first. Fix: decide the final at the battle, not at the rift.

### 33. Fixed 25 October (`docs/measurements.md`). Measurement: the tender and the run share one random stream
`Campaign.tender` seeds a generator of its own with the run's seed, and the run seeds its own
with the same number (sim/campaign.gd:147, :118), so both streams are one. The party's deal
uses "a stream of its own" (sim/campaign.gd:161) for exactly this reason. Two effects, traced
and reproduced with a model of Godot's PCG32 (it matches `docs/campaign_run.md`'s 22 October
start table to the run: the Honey Badger 9, the Armadillo 20, the Puffin 28, the Prairie Dog
12, the Cassowary 12, the Cottonmouth 7, the Baboon 18, the Stingray 14):
- The runner's "random" pick of three isn't. The shuffle's first draw reuses Minerva's offer, so
  over 4,000 seeds today the Armadillo starts every run it is offered (1,975 of 1,975), the
  Badger about half (1,010 of 2,025), every other machine about three in four. Whatever the
  runs say about the Armadillo or the Badger rests on that coverage.
- With the player's own pick, the first rifts reuse the tender's numbers: an Armadillo offered
  means the first rift opens at Kestrel's or Aphelion's city, a Puffin that its lead is the
  Meadow or the Marsh, a Skua the Waste or the Peak.

Fix: give the tender a stream of its own, as the party has; the runner's pick too.

### 34. Question: the Honey Badger's "never destroyed" piles up cracks for a wreck to take
"Components can be cracked but never destroyed" holds in the fight, so a Badger's cracks never
turn into losses there; but a wreck "also loses its cracked components" (docs/rules.md:676),
and `_after_battle` never asks the passive (sim/campaign.gd:511). A wrecked Badger loses every
crack it banked, its passive's protection turned into the biggest loss on the roster. The
Badger's brief planned "never destroyed" to move to a module "where its campaign meaning
survives". Ryan's call: does the passive spare a wreck's cracks?

### 35. Fixed 25 October, with 22. Latent: a resumed battle's boss isn't marked as ended
`Battle.lineup` and `escort` aren't saved (sim/save.gd:52), and `finish_battle` reads the
lineup to record the boss as ended (sim/campaign.gd:396), so a battle resumed from a save
records no boss and the domain may draw it again. Harmless while each domain has one boss; it
bites when the bosses' slate lands ("one of its domain's bosses that its battles have not
ended", docs/rules.md:686).

### 36. Small ones
- The save keeps neither a fight's Sponsorship tally (zeroed by a resume mid-fight) nor a rank's
  shared pick (`_focus`), so after a resume a Disrupt on a focus-aim foe (the Cleric, the Augur,
  the Summoner) draws a fresh pick and the fight runs apart from the unbroken one. The screen's
  die locks clear on a resume too.
- The harness fields only a faction's first boss whatever boss is chosen (sim/harness_setup.gd
  :191), latent until a domain has two; the map viewer's sample packs are made with a move of
  2 and never move (sim/loadouts.gd:91).
- The profile's pool takes the eight basics every run starts with (sim/profile.gd:25), where the
  pool is "blueprint ids found in any run"; a finale won credits the capital's rolled domain
  with a boss beaten, and so a beaten domain in the codex (sim/campaign.gd:395); `absorb` has no
  once-only guard.
- A thinned domain can still be a rift's guest (sim/campaign.gd:595): the rules allow it, the
  bible's "thins that domain from the rifts" reads either way. Ryan's call.
- Comments that drifted: a wreck sits out SHOP_BATTLES "battles" (it is turns, a pass counting,
  as docs/rules.md:676 says; sim/campaign.gd:29, :64); a promoted form's "armour 5" (it is 2,
  sim/content_db.gd:107); the profile's codex of "chassis and foe ids" (it holds faction ids,
  sim/profile.gd:11).

## Content and shown text

### 37. Bug or intent: the Zombie Knight never appears in a run
The Marsh's spawn list is the Revenant ×6, the Revenant ×6 again, the Ghost ×3
(content/factions.json:45), and nothing else deals the Knight, so no run, final escort or
balance cell meets it; only the harness's pack picker fields it. The bible's domain table gives
the Marsh's wildlife as "Revenant, Ghost, Zombie Knight", its niche "the Marsh's one armoured
foe", and the rules cite "the Zombie Knight's 8 HP" (docs/rules.md:183). If the second Revenant
was meant to be the Knight, it's a one-word fix.

### 38. Text: the promoted forms show their heroes' codex
A promoted entry sets no codex and takes its hero's (`_resolve_promotions`,
sim/content_db.gd:112), which the class change contradicts: at the finale the massive,
front-rank Summoner reads "a small figure in the back rank ... reach the back rank before the
circle opens", the Cleric "stands behind the dead", the Augur is "at the back", and the Martial
Artist, armour 2, "no sword, no armour", beside a stats line that says MASSIVE // FRONT RANK.

### 39. Text: codex lines that promise what the engine doesn't run
- The Needler's "needles are exactly ten, every time": it hits 3 (its move's own text prints 3).
  A number from before the stock pass.
- The Thief's "when it is hurt it leaves, and it will be back" and the Salamander's "its bites
  burn, and so does its hide": Flee and Ember Hide are planned, and the Salamander's bite lays
  Scorched, not Burning.
- The Zombie Knight's "the first time you put it down it gets back up": only once it has picked
  Reraise (weight 1 against its Cleaver's 2, when hurt); killed from whole it stays down.
- The Whip Scorpion's "Nothing else cools it": an ally's vent and Cryo cashing cool it, as the
  rules themselves say (docs/rules.md:572).
- The Kite's codex still calls it "the Sparrowhawk" (content/chassis.json, `sparrowhawk`).
- Smaller and Ryan's prose to judge: the Gel "hits back" (it has one move and no reaction); six
  Revenants "arrive for every one you put down" (packs never escalate); the Magma Elemental's
  "biggest telegraphed hit ... every round" (Slag Fist shares the roll with two specials); the
  Warrior "stops picking targets", the Black Mage "stops throwing fire", the Cleric has "one
  spell left" (each below-half move joins the pool; the others stay legal).

### 40. Text: the vocabulary has drifted from the engine
- "Overcharged a kill" gives "two" stacks (content/vocabulary.json, `kill_overcharge`); the
  Soulcutter Talons lay one (`devours: 1`), as the rules say (docs/rules.md:256).
- Paradox: "a foe already suppressed loses its next action instead". The engine wastes the trip
  (sim/skirmish.gd:2871), and the rules say it "gains nothing" (docs/rules.md:373).
- Cracked component: "loses its keywords and unique effects" (item 5).
- Smaller: Suppress and Suppressed say "this round" (the rules: or the next, when it has acted);
  Direct's entry omits the Exposed status, the Aim entry omits "buffed".

## The validator

### 41. Gap: the Rapid tier rule isn't enforced, and a test asserts the opposite
"A Rapid vent is never below tier three ... and a Rapid shield never below tier two"
(docs/rules.md:219), but the validator checks only the limiter (sim/content_db.gd:936), and
`test_rapid_rides_on_anything_and_shock_on_weapons_only` builds a tier-one Rapid Coolant Jacket
and asserts "a rapid vent validates" (tests/test_content.gd:1418). Today's content complies.

### 42. Other gaps
- No unknown key is refused anywhere (faces, components, chassis, modules, factions): a typo
  such as `"cooldwon": 0` is ignored in silence, and a field on the wrong kind passes
  (`power_max` on a shield prints "6–10" for a shield that always gives 6, sim/face.gd:661).
- `heat_max` is no required chassis key, and its fallback is 60 (sim/content_db.gd:188), five
  times the scale.
- "A Barrier is never granted to every ally at once" (docs/rules.md:337) is unchecked: a
  `reaches_all` Barrier passes.
- Negative or fractional numbers pass or are floored to nothing in silence (a face's heat, an
  add_ceiling, a free_reroll); a `multiply_heat` of 0 passes and would strip a Rapid piece of
  its heat limiter.
- Planned drafts are offered and run in the harness (game/harness.gd:148, :301): the planned
  chassis and components appear in the pickers and run as their built parts (the St. Elmo's
  Regenerator as a plain Lure), where a draft is "kept, not shown, not run".

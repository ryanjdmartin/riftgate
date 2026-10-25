# Mechanics audit, 25 October

Ryan's ask, after the Flak fix (Flak added nothing to a blow lowered to 0): a sweep of the
game's mechanics for anything that doesn't add up, doesn't seem right, or doesn't match the
records. Read from the code (`sim/`), the content and the records (`docs/rules.md`, the
bible); Godot could not run in the session that wrote this, so every finding was traced
through the code by hand and is cited by line, never measured. The Flak fix itself is left
out (a note on its follow-ons closes the skirmish section).

How to read it. Each finding carries a kind:

- **Bug**: the code does something the records don't say, and today's content reaches it.
- **Latent**: the same, but no content reaches it yet (it bites when content lands).
- **Text**: shown text or the records say something the engine doesn't do.
- **Question**: the code does what the records say, but it defeats the mechanic's own purpose,
  the Flak kind of problem. Ryan's call; each carries Claude's lean, never a decision.

Nothing here is decided. It retires once its findings are fixed, struck or turned into rows
and tasks.

In progress: the skirmish section is complete; the map, the campaign and the content's shown
text follow, each finding checked against the code before it lands here.

## The skirmish

### 1. Bug: a Gel's split and a Ghost's summons join their pack, so a pack can grow
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
(docs/rules.md:614, :644). The same count undercounts kills: `kills_for` is strength less
survivors, floored at 0 (sim/skirmish.gd:290), so the two dead Gels above score 0 kills and
0 salvage, and a full clear of a 4-Gel pack scores 4 for its 12 kills. Boss units are safe
(their escort counts `escorts` only). The map bot never withdraws, but a fight it loses
while other machines stand on the map leaves the pack grown the same way, so
`docs/campaign_run.md` can carry it. Fix: count a pack's survivors by its own foe type (a
risen one included), and its kills from the foes that fell.

### 2. Bug: Overshield's excess outlives a fight that ends mid-turn or by withdrawal
The excess is trimmed only in `end_round` (`_trim_overshield`, sim/skirmish.gd:1353). A
fight won mid-turn ends at once (`_check_outcome`), and a withdrawal skips the round's end
(sim/skirmish.gd:1698), so neither trims; `finish_skirmish` doesn't clamp
(sim/battle.gd:699), and `Unit.recharge_shield` keeps a shield already past its maximum
(sim/unit.gd:264). The Puffin's Backwash Ionizer ("until round end", its codex) on an ally at
full shield, then the last kill that turn: the ally walks the map 3 over its maximum and opens
the next fight with it, through that fight's first enemy turn. Fix: trim at `_finish`.

### 3. Bug: the Spin-Up can chain into itself for free
The rules and the bible say both "the Spin-Up spins the whole die, the entry showing
included" (docs/rules.md:99) and "its limiter is the cylinder, since it cannot chain into
itself" (docs/rules.md:217; the bible's Cassowary row says both in one sentence). The first
is what runs: `_act_again` makes a spin a true roll over every entry, itself included, before
it asks whether the die steps (sim/skirmish.gd:2270). With cooldown 0 and no heat, a
Spin-Up that lands on itself (one in six on the Cassowary's six entries) goes again, a Spun
Up stack a time, without end. The validator exempts it from the limiter rule on the stepping
die alone (`_locked_on_stepping_die`, sim/content_db.gd:936), and the bible's own exit says
"a stepping-die piece that ever makes a free chain gets a limiter of its own". Small in
expectation (a fifth of a spin more a spend), unbounded in principle. Question for Ryan: a
limiter (a heat, or the spin never landing on itself), or keep the spin and strike the
exemption's premise.

### 4. Bug: a rally's Kindled is multiplied by the move's factor
`Foe.damage_of` adds Kindled to the base attack before the move's factor
(sim/foe.gd:176), where Kindled says "hits {value} harder" (the chip, the rally's text,
docs/rules.md:406) and the bible gives it the job of "lifting a small blow over the plate".
With the Magma Elemental's Stoke the Forge (+2): the Bomb's Flare Up (0.34) goes 3 to 3, **+0**;
the Sandworm's Quake and the Martial Artist's Hundred Fists +1; the Lancer's Dragon Dive (1.5)
+3; the Black Mage's Flare and the Augur's Omen (2.0) +4; the White Mage's Holy (3.0) **+6**,
which the finale can field beside a standing Magma Elemental. The intent number is right (it
reads `damage_of`); the promise isn't. Fix: add the rally after the factor, as the Kite's
double adds the buffs once after the printed number.

### 5. Question: a cracked or silenced Volatile piece loses its price and keeps its number
Volatile is a keyword, and a crack clears keywords (`Face.crack`, sim/face.gd:630;
`volatile_cost` reads the keyword, sim/skirmish.gd:489), so a crack takes the hull price
away and leaves the number. The Oblation Mantle (shield 10, Volatile 3) and the Entropy
Condenser (vent 10, Volatile 3, the capstone "paid in hull") are strictly better cracked; the
Umbra Inducer loses its Suppress with it, so it nets out. Silence does the same by the
rules' own words ("a Volatile bites nothing", docs/rules.md:363), so a foe's silence frees
them too (no foe carries silence yet). An injury and the enemy's answer should never be an
upgrade. Lean: a price outlives a crack and a silence (as a printed cooldown already does,
docs/rules.md:225), Volatile read as a price rather than a keyword.

### 6. Question: the Ward turns away no special, and the Peak's scorch is mostly specials
The Ward stops riders on blows only (sim/skirmish.gd:1528), plus the silence and purge
specials (sim/skirmish.gd:2225, :2231), as the rules say (docs/rules.md:338, :514). The bible
gives it the job of answering "the Waste's breach and the Peak's scorch". The Peak's heaviest
heat is specials: Eruption, Fira and Pyroclasm (Scorched 4 on every machine), the Drake's
Stoke (Burning 4), with the Summoner's Diamond Dust (Corrupted) and the Cockatrice's Stone
(Disabled) alike; the Ward answers only the 2-stack scorch on blows (the Bomb, the
Salamander, the Drake's Breath, the Black Mage's Fire). Lean: a Ward turns away the debuff
specials on its machine as it does the riders.

### 7. Bug: specials on every machine reach a Phased one
A blow at every machine skips a Phased machine (sim/skirmish.gd:1456), but the scorch-all and
corrupt-all specials walk `live_mechs()` (sim/skirmish.gd:2237, :2243), so a machine the
Mooring Screens Phased still takes Eruption's Scorched and Diamond Dust's Corrupted. Phased
"cannot be targeted" (docs/rules.md:312). Fix: skip Phased there too.

### 8. Bug: a sprayed spend's Primed burn all lands on the first foe
A Primed machine's Burning is summed over the strikes and laid on `target` after the loop
(sim/skirmish.gd:1925), so a Skua's Flechette Pod whose strikes fell on three foes puts every
stack on the first. Primed lays its stacks "on its target" (docs/rules.md:311), each blow's
own. An ally's Aurora Lattice reaches the Skua today. Fix: lay it on each strike's own foe.

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
not only at 1. One or the other moves.

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
through `_add_heat`, so an on-heat-gain passive (the Boundary Layer Bleed's shield) never
answers it. Every other heat in the fight goes through `_add_heat`.

### 18. Text: the Stingray deepens most stacks it lays on itself, not all
"Every stack this machine applies, to a foe, an ally or itself, is one deeper for every 5
heat." A brace's Armoured, the Stoker's Burning on its own firer and a passive's own stacks
don't pass through `_stacks_from` (sim/skirmish.gd:1279, :1287; `Effects.fire`). The Stoker
is a hardpoint piece, so a Stingray can carry it.

### 19. Bug, small: the Cottonmouth's Spread carries a consumer's bonus to the neighbours
A consumer's point a stack is added to the roll (sim/skirmish.gd:1809), and the roll reaches
every foe the blow does. "One blow on one foe (no strikes past one, no area)"
(docs/rules.md:266), but the Cottonmouth's drum grants Spread at the front, so its Backdraft
Charge pays the burning target's stacks to its neighbours too.

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

### The Flak fix's follow-ons
The same "a blow of nothing stays nothing" gate lives in four more places, which a fix in
`Effects.damage_taken` alone leaves behind: the die's number (`shown_number`,
sim/skirmish.gd:364), the bot's (sim/policy.gd:1005), and the strike's own reads of "did it
deal anything", on the attacker's number before Flak: spending a Shocked (sim/skirmish.gd:1859,
:2605), laying a passive's stacks (:1864) and cashing Cryo (:1900). Once Flak lifts a 0 to a
1, whether that strike spends the shock, lays Vitriol and cashes Cryo wants one answer.

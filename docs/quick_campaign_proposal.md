# The quick campaign: a proposal

Ryan opened it on 25 October: a mode "useful for testing but also a potential 'quick campaign'
mode" that mimics Slice and Dice's flow with the map and the cities cut out. This file holds
its shape, the holes in it and the questions until Ryan has picked; then the picks become bible
rows, `docs/rules.md` and code, and the file retires (git keeps it). Everything here is Ryan's
to move, the name included (his working name).

## Ryan's shape (25 October)

- A run of battles with no map and no cities. A battle is skirmishes back to back against full
  formations of one domain (the Marsh, the Peak, ...), one formation for each Fracture the
  Rupture needs, elite encounters between them as the tier calls for, then the boss:
  - tier one: formation, formation, elite, formation, boss;
  - tier two: formation, formation, elite, formation, elite, formation, boss;
  - tier three: formation, formation, elite, formation, elite, formation, elite, formation, boss.
- A loot pick after each skirmish: random components or modules of that tier.
- After the boss, a full heal and a pause for the battle's rewards: a component unpacked from
  the boss's token (in place of a blueprint), and the host maker's offer with the maker drawn
  from all makers at random.
- The next battle's domain drawn at random, its tier following the ramp and the tier steps of
  `docs/curve_proposal.md` (still open), so the curve can be felt without a whole campaign.
- Components and chassis switch freely between battles, never between skirmishes: a
  trimmed-down hangar, the game's first try at one.
- His caveats: far from a perfect stand-in for a campaign's balance, but near enough to feel
  how the ramp and the enemy tiers play, and a balance stress test, since every fight is a
  complete formation.

## What it can read, and what it cannot

It reads what the campaign runner cannot: a squad that fights every fight together. The
runner's plain player fights mostly alone and ends 98% of its battles in a team wipe
(`docs/campaign_run.md`), so the campaign report says nothing yet about a run's growth
(section 12's campaign question). A quick run reads the wear a battle costs, the kit a run
gathers by tier, and the boss and the finale against a squad built from what it found, which is
the read section 9's finale row waits on ("It reopens if a built squad of four is walled there
too").

It cannot read the map (detachments and small packs, hunters, pushers on the gate, an elite's
map mechanic such as the Reaper's hunt or a blitz on the gate, and Rift Pressure, so the ramp's
spawn rate has no form here and its density only one, the size of a formation) or the cities'
side (Favour, salvage, the bleed).

And today the enemy does not move with the tier. Every tier draws the same spawn lists at the
same density (section 3's curve row: not built), no elite is in content, and each domain's one
boss is its massive foe standing in until the slate lands. Until the foes' fresh start, a quick
run's last battle fields what its first did, so it reads the player's kit rising against a flat
enemy: its tier three is longer, not harder. It is the harness the enemy's tiers are read in
once they exist, and that is its strongest case.

## The holes, with Claude's leans

**1. The fights a battle holds, against the squad that fights them.** Ryan's counts tie the
formations to the Rupture's Fractures (three, four or five by tier: section 4's pacing row) and
add an elite a tier, so a battle runs five, seven and nine fights with the boss, every one the
hardest kind a battle holds, and nothing heals until the boss is dead. A probe of the shape
(`tools/chain_probe.gd`; `docs/measurements.md`, 25 October; greedy play, a direction): a squad
fights one domain's formation up to nine times in a row with its damage carried. The share still
winning after the fourth, the sixth and the eighth formation, the fights before each tier's boss:

| Squad | Between fights | Four | Six | Eight |
|---|---|---|---|---|
| A starter trio (the 44 a tender deals, stock) | no shield back | 32% | 14% | 6% |
| | a field recharge | 43% | 29% | 19% |
| A starter four (the 24, stock) | no shield back | 84% | 70% | 56% |
| | a field recharge | 89% | 80% | 71% |
| An endgame four (the five of 23 October, fitted to tier two) | no shield back | 100% | 100% | 99% |
| | a field recharge | 100% | 100% | 97% |

Three things follow. A trio cannot carry the shape: more than half the stock trios fall before
tier one's boss, and that is before an elite stands in one of the four fights. A fourth machine
about halves what each fight costs (section 4's four-machines row: concentration halves the hull
a fight costs with every machine added), and with four the counts hold from the start; the Meadow
is the hard domain, a stock four winning four of its formations in a row two times in three, or
three in four with the recharge. The recharge is worth five to fifteen points. And the end is
soft: a four fitted to tier two loses about a thirtieth of its hull a formation and leaves tier
three's eight with three quarters of it or more (76%, 84% with the recharge), since the enemy
does not move with the tier (above).

Claude's leans: the run starts with four (hole 10), one field recharge between fights (hole 4),
the counts as Ryan wrote them and a setting the runner reads, and the late formations denser
(hole 3), so the end presses a built squad. The pacing row's "four to five meaningful skirmishes
and then the boss, the count flat across tiers" (Ryan, 13 October) is a campaign battle's, which
mixes small packs with formations; if a quick battle is to keep it, an elite counting a Fracture
(the tiers row: worth "a larger chunk of the Rupture meter" than a pack) makes battles of four,
five and six fights, the threat rising by the mix.

**2. The elite slots have nothing to field yet.** No elite is in content. The candidates Ryan
has marked (`docs/bosses_proposal.md`): the Meadow's goblin shaman, the Elder Treant and perhaps
the Leshy; the Waste's Old Man of the Desert; the Marsh's Reaper, and the Bone Wyvern, built but
standing in as the Marsh's boss; the Peak has none. And each domain has one big foe, its boss's
stand-in, so an elite stood in by the massive foe would meet the same foe again as the boss. The
stand-ins, one line each:

- The domain's other bench hero, the one the party did not deal, leading the formation (in its
  rank, the formation in the other columns, as a final stands its hero): built, distinct from
  the boss, and a curveball by its signature (the Lancer's Jump, the Cleric's Cure, the Black
  Mage's Flare); its cost is the fiction, since the heroes are the party's.
- The domain's massive foe inside its formation: the harder fight, the shape Ryan's terms give a
  tier-one elite and where the Treant, the Elemental and the Sandworm are headed as rank and
  file; the same foe as the boss, twice a battle.
- No elite slot until the first elites land, the tier then differing by the formations' count
  alone.

Claude's lean: the slots read content (a domain's `elites` beside its `boss`), the first elite
set proposed in chat and landed with the mode (one a domain at least; the Peak's still to find),
and until a domain has one, its other bench hero stands in, labelled. The boss: today's boss
with its formation, which is the pacing row's exam ("the boss with its formation"); the slate's
bosses take the slot as they land, four of them on today's engine (the Rotbloom, the Phantom
Train, the Matador, the Adamantoise), their kits proposed in chat first.

**3. A domain has one formation, so every formation in a battle is the same fight.** A formation
today is the domain's whole spawn list in one fight, as `tools/balance.gd` builds it: the Meadow's
and the Marsh's fifteen foes, the Waste's and the Peak's nine, deployed heaviest first, ties in
arrival order, so the same list stands the same way every time. Variety waits on the fresh
start's compositions (a front and a back spawned by the rift) and on the guest (hole 8). Before
then, the one ramp lever this mode can carry is density: a knob on the formation's strengths,
which is pack count (section 3's never-inflate row allows it) and the curve row's own early and
late ("less dense formations", "very dense formations"). It moves a built squad: with the
recharge, a tier-two four gets through eight formations in a row 97% of the time on 84% of its
hull at today's density, 90% on 66% at half again as dense, and 66% on 60% at double
(`docs/measurements.md`, 25 October). Claude's lean: the spawn list whole at tiers one and two,
so a quick run's fights read like the balance report's formation cells, and denser at tier three,
the step a placeholder the runner reads.

**4. Shields never come back between fights.** By the battle's rule a machine regains its field
rate only in a map turn it spends out of a fight, and here every machine fights every encounter,
so a battle's shields run down and stay down, harsher than any real battle, where the squad
walks a turn or two between packs. Claude's lean: one field recharge between encounters (and the
out-of-combat passives), standing in for that walk. Hull never heals in a battle, cracks stay,
wrecks sit out the rest of it, and heat starts each fight at zero, as now.

**5. The loot.** Four points:

- The pick after each skirmish stands in for the map's loot (the wrecks a mode without a map
  cannot have), not for the Fracture's pick, which the bible keeps temporary (section 8: a
  battle-long modifier, a one-shot or a boon, "temporary upgrades amplify the build, never
  replace it"). Once the Fracture picks are built, a won formation can carry both.
- "That tier": the curve proposal's calls make it a mix, a tier-two battle still dealing cheap
  tier-one pieces and tier three a chance (none in tier one, small in tier two, larger in tier
  three). Claude's lean: the mix, so the quick run is where the drop table the campaign will run
  gets tuned; a pick of three, components and modules together, never a locked piece, a basic
  or a planned one, never the same thing twice in one pick.
- Tier three is thin: two unlocked components (the Umbra Inducer and the Gravity Knuckles, both
  the Arsenal's weapons) and three modules. A tier-three token, at the rift's tier and never below
  (Ryan's call), cannot be a choice of three components. Claude's lean: a choice of the two and
  a tier-three module until the makers' sessions widen the tier, which this mode makes visible.
- The token's theme ("of the domain's theme") is open (section 12's question on what a themed
  token draws from). Claude's lean: the whole pool at the tier until it is answered, a choice of
  three as the campaign's token.

**6. The offer.** "All makers" would bring in the Arsenal, which never offers in the tender,
sells only its trickle at the capital as the Convergence opens it, and fields no tier-one chassis.
Claude's lean: the four city makers, the offer being a city's; the Arsenal's pieces still reach a
run through the loot and the token at their tiers (both tier-three components are its). The
offer itself as the campaign's: a chassis, a component and a module of that maker, one taken
free; the chassis runnable, at or under the battle's tier and not one the roster holds (for
breadth; Aphelion has two chassis, both tier one), bringing its stock as a bought chassis does;
the component at the battle's tier, the module at or under it.

**7. The run's length, its end and losing.** One battle a tier is five, seven and nine fights,
21 in all, about Slice and Dice's twenty; the campaign's schedule (the Convergence a battle, a
tier every four) is twelve battles and 84 fights, a whole campaign's length. The ramp, rising
battle by battle, only shows with more than one battle a tier. The end: tier three's boss, or a
finale after it (the party promoted, as at the capital), which is the finale row's read on a
built four. Losing: the campaign's graded loss grades a city's gate, and this mode has none, so a
team wipe ends the run, as in Slice and Dice; section 10's "no loss ends a campaign early" is the
campaign's and stays so. A withdrawal stays open as in a battle (the volley taken), and costs the
encounter: no pick, no Fracture, a fresh formation in its place. Claude's leans: one battle a tier
by default, the count a setting the runner reads; the finale as the last fight; a wipe ends the
run.

**8. Guests.** The campaign's rifts carry a guest from tier two (the code's tier 1), its packs
alternating with the lead's. Ryan's shape keeps one domain a battle. Claude's lean: one domain at
tier one; from tier two a guest whose formations alternate with the lead's, the elites and the
boss the lead's, so the guest is part of the tier step and the formations vary.

**9. After the boss.** Claude's lean: the campaign's after-battle rule (hull and cracks mend free;
a destroyed hardpoint piece is gone, a destroyed fixed one rebuilt; a wreck loses its cracked
pieces too), without the wreck's battle in the shop, since there is no Favour to rush it with and
a battle is a third of a run. The eight basics free and unlimited in the hangar, since the run
starts with their blueprints and has no salvage to build with, so no hardpoint sits empty for
want of a piece.

**10. The start.** The campaign's is a tender of one tier-one machine from each city maker, take
three, and the fourth is bought from the shelf; a quick run has no shelf, and a trio cannot carry
its shape (hole 1). Claude's lean: the tender's four, all taken, so every maker is heard and the
squad section 2's tests are read on fights from the first battle; the offers' chassis then grow
the roster past the squad, which is what makes a chassis worth switching between battles. The
draft's choice goes with it; a tender of two a maker, take four, would keep one.

## What it would take

- Headless, in `sim/`: the run (its battles, encounters, picks, rewards and end), the hangar's
  verbs without prices (fit, strip, the squad, modules on a machine: the campaign's machines carry
  none yet), and the save (a run and its open fight survive the phone killing the app, section
  11's save row); tests beside it.
- The runner (`tools/quick_run.gd` into `docs/quick_run.md`): whole quick runs, the fights by
  `Policy`, the picks and the fits by a plain policy (the runner's player fits nothing today), the
  report by battle, encounter and tier: runs won, where runs die, hull left before each boss,
  wrecks, the picks taken by tier. A verdict on its picking and fitting is a verdict on the bot.
- The screens: the tender, the battle's track (the encounters as a row, the one under way lit),
  the pick of three, the rewards, the trimmed hangar (the roster, the squad of up to four, a
  machine's entries in order with its module slots, fitting from the stores and stripping back,
  the codex on a hold, GO), and the end; an entry from the harness. Judged running on the phone.
- For the tiers to mean anything on the enemy's side: the fresh start's formations by tier, the
  elites and the slate.

## The order of work

Claude's lean: the headless half first, a session of its own. It reads the wear and the finale on
built squads now, which the campaign runner cannot, and it is the harness the fresh start reads
its formations and elites in, so it sits before the foes' fresh start (the status's third item).
The screens follow, the first hangar the screens step needs anyway, and the elites and the slate
fill the slots as they land.

## Questions for Ryan

1. The run starts with four, the tender's four all taken, since a trio cannot carry the shape?
2. The counts as written (five, seven and nine fights with the boss), or an elite counting a
   Fracture (four, five and six)? And the late formations denser?
3. A field recharge between fights, or none?
4. The elite slots until the elites land: the other bench hero leading the formation, the massive
   foe in its formation, or no elite slot yet? And which comes first as content, the first elites
   or the slate's first bosses?
5. The loot at the curve proposal's mix, or strictly the battle's tier; the tier-three token as
   the two components and a module?
6. The offer from the four city makers, or all five?
7. One battle a tier, then the finale? A wipe ends the run?
8. A guest from tier two, or one domain a battle throughout?
9. The headless half first, before the screens?

## The bench

Ideas a rule kills here, one line each with the rule, so Ryan can overrule the rule:

- The foes' numbers ramped by tier so the later battles bite before the fresh start: section 3's
  never-inflate row (difficulty by smarter foes and nastier compositions, never inflated rank and
  file).
- A heal between skirmishes: the rules' "hull never heals in a battle" (section 4's damage-sticks
  row).
- A refit between skirmishes: Ryan's own shape, and the campaign refits after a battle (the
  rules' campaign part).
- A wreck lost for the run: section 10 refuses permadeath ("wrecks are recoverable").
- The Fracture's pick as the per-skirmish reward: section 8's pick row keeps it temporary and not
  loot; it is not built.
- Command entries as a reward: section 8 ("never from rewards").
- The Arsenal's chassis on offer from the first battle: section 1 (its tiers open only as the
  campaign turns dire) and the tender row (the Arsenal never offers).

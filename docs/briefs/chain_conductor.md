# Brief: Chain, the conductor (keyword rework, decided; the build written out)

The session builds the Chain keyword's new form: the blow arcs to every Shocked foe on the
field. Decided 28 October (Ryan, on Claude's proposal in chat; the bible's Chain row in section
5), the kill and repeat and the ping retired. This brief is the build, written so that nothing
in it is a guess: where each change goes, what each edge case does, and the tests that prove
it. Where it says "decide nothing", the choice is made here.

**Status**: decided, not built; this brief is kept until its engine lands, then it retires (git
keeps it). **Order**: after the pricing pass's fills (landed 28 October); before the heat session
(`heat_pillar.md`), which does not touch it. **Read first**: `CLAUDE.md` (the rules on enums as
`int`, synthetic passives in tests, the watchdog on every headless run); `docs/rules.md`
("A blow", "Reach", the keywords list, "A mine"); the bible's Chain row, area row, blow's order
row and randomness row (section 5), its maker row (section 7); `sim/skirmish.gd`
(`reached_by`, `area_shapes`, `area_number`, `_area_blow`, `_area_shot`, `_shot`,
`_resolve_attack`, `_mine_hit`, `field_foes`); `sim/face.gd` (`NUMBER_FIELDS`,
`AREA_KEYWORDS`, `from_dict`, `to_dict`, `duplicate_face`, `add_keyword`, `number_of`);
`sim/policy.gd` (`attack_score`'s area loop, `damage_outcomes`, `mine_score`, `_area_mean`);
`sim/content_db.gd` (the numbered-keyword checks on components and the `grant_keyword` checks);
`tests/test_skirmish.gd` (`test_chain_repeats_on_a_kill`,
`test_a_chain_mine_that_kills_its_arrival_repeats_the_attack`); `tests/test_content.gd`
(`test_keyword_cap_is_enforced`, the `grant_keyword` cases); `content/vocabulary.json`
(`chain`, `shock`, `shocked`); `content/components.json` (`arc_fault_cannon`).

## The rule, exactly

**Chain N**, a weapon's keyword with a number, printed on the die as Burn N and Splash N are:

- When the entry is spent on a foe, every strike also lands a blow of N on every other Shocked
  foe on the field: alive, carrying the Shocked status, and not the foe the strike is aimed
  at. Wherever it stands: front rank or back, in the gun's reach or not. Reach is never read
  for the arc (Ryan, 28 October: "we're not selling indirect reach, we're selling a conversion
  of single target burst to AoE").
- The arc is a blow of the spend, read in the blow's order exactly as a Splash blow is: N plus
  what the entry prints from its firer (heat fired, hopper loads), a split's share, through the
  firer's modifiers judged on that foe (adds, multiplies, floors), then the foe's own reads
  (the hull it is missing, the stacks a consumer eats), then its statuses (Shocked doubles the
  blow and is spent; Flak adds), then its armour (none against a Breach), then the hull. The
  Kite's double multiplies the arc's N as it multiplies an area's N. A Barrier eats the arc
  whole and the Shocked is spent on the Barrier. A Ward turns the marks away as on any blow.
- The riders land on every foe the arc strikes (Burn N, Flak N, Cryo N, Web, Suppress with its
  gate judged at the spend, the player's Purge), the kill triggers fire (a kill rule's
  Overcharged, the drone's mine, the hopper's fill counting the foe as reached, the reset gun's
  `killed`), and Spillover spills past a front-rank kill as any blow of the entry does. Heat is
  paid once a spend; an arc adds none.
- Nothing charges itself: Chain reads Shocked and never lays it. A Chain entry that also
  carries Shock (none today) lays its Shocked after its blows as Shock does, so its own arcs
  never read what it lays.
- The foe the strike is aimed at is never a conductor; its own blow spends its Shocked as today.
- A foe both in a geometric shape (beside the target for Spread, the other rank for Penetrate
  or Splash) and Shocked takes one blow, the geometric shape's number; its Shocked doubles that
  blow and is spent. One blow a foe a strike, as today.
- Twins (the Gel's halves): a half is a conductor only if it is Shocked itself; the arc reaches
  no twin whole (that is the geometric shapes' rule, `has_area()`, which Chain does not join).
- Order of the arcs: `field_foes()` order (the front rank left to right, then the back, a
  twin's right half after its left), after the target and the geometric shapes. Deterministic;
  nothing random.
- Strikes: for an entry that is not a spray, `hit` and `shapes` are read once a spend (the code
  today), so a two-strike Chain gun arcs twice to the same conductors; the first strike's arc
  spends the Shocked and the second lands undoubled. A spray reads them again each strike, so
  a conductor spent by one strike is no conductor for the next. No Chain piece has strikes
  today; this is the rule if one does.
- Silenced: the keyword is muted with every keyword (`Effects.effective_face`,
  `keywords_muted`), so no arcs. Nothing to build, one test.
- A debuff never carries Chain: the validator refuses `chain` on an attack whose number is 0,
  and `reached_by` adds conductors only when `not f.is_debuff()`. (A debuff's arc would carry
  its riders to every Shocked foe for no blow: a stun on every conductor. Not this keyword.)
- A mine laid from a Chain entry carries its arc number as laid, through its spender's
  modifiers with no foe in hand (as the row's and the column's numbers travel), and as it lands
  on its arrival it arcs that number to every other Shocked foe on the field at that moment.
  The mine's old kill and repeat goes.

## The engine

`sim/face.gd`:

- `var chain: int = 0` beside `splash`, with the comment "an attack with Chain: the number
  every other Shocked foe on the field takes as its blow's (Chain N, 28 October)".
- `NUMBER_FIELDS` gains `Keyword.CHAIN: "chain"`. `AREA_KEYWORDS` does not (it is the
  geometric shapes: `has_area`, the twins, the drum's grants).
- `from_dict` parses `chain` as it parses `splash` (`maxi(0, int(d.get("chain", 0)))`);
  `duplicate_face` copies it; `to_dict` writes it for a weapon that has the keyword and a
  number above 0 (beside the area loop, with the same debuff exclusion).
- `add_keyword`: a Chain added with no number says 1, as an area keyword does (extend the
  default to `Keyword.CHAIN`).
- `KEYWORD_LABELS`: "Chain" stays. The die's marks text and the codex print "Chain 2" through
  `NUMBER_FIELDS` and `number_of`; confirm on the harness (hold the die on the Buzzard's Arc
  Fault Cannon).

`sim/skirmish.gd`:

- `const AREA_CHAIN := 4   # every other Shocked foe on the field: Chain's (28 October)` beside
  `AREA_ALL`.
- `reached_by(f, target)`: after the row, the column and the twins, and before `return`:
  `if f.has(Face.Keyword.CHAIN) and not f.is_debuff(): for foe in field_foes(): if foe != target
  and foe.alive() and Effects.has(foe, "shocked") and not hit.has(foe): hit.append(foe)`. The
  `reaches_all` early return (the Siphon) already holds every foe; put the conductor step before
  it so a Chain on a lure-all (none today) still maps its shapes below.
- `area_shapes(f, target)`: the same walk, mapping each conductor not already in `out` to
  `AREA_CHAIN`, and overriding an `AREA_ALL` (whose number is nothing).
- `area_number(f, shape)`: `AREA_CHAIN` returns `f.number_of(Face.Keyword.CHAIN)`.
- `_resolve_attack`: delete the kill-and-repeat block at its tail (the `for cand in
  targets_for_face(ms, real)` loop guarded by `f.has(Face.Keyword.CHAIN) and not target.alive()`,
  with its `_chaining` save and restore). The strike loop needs no change: a conductor in `hit`
  with `AREA_CHAIN` in `shapes` takes `_area_blow(ms, f, AREA_CHAIN, foe, own, split)` plus its
  own reads, and the loop's existing lines spend its Shocked, land the riders, fire the kill
  triggers and log "the shock lands, N doubled". Add one log line per conductor, before the
  blow's own lines: `"%s arcs to %s" % [ms.unit.display_name, foe.display_name]` (the tests and
  the feed read it; the old line was "chains to").
- `_chaining` stays: the strikes use it.
- `_area_shot(ms, f, own, split)` returns a third number, the arc's:
  `_area_blow(ms, f, AREA_CHAIN, null, own, split)` when `f.has(Face.Keyword.CHAIN)`, else 0;
  `_shot` stores it as `"chain"`. `_shot_text` is unchanged.
- `_mine_hit(foe, shot)`: after the row and the column and the twins, when `kws` has
  `Face.Keyword.CHAIN` and the shot is a weapon's: every alive Shocked foe on the field but the
  arrival joins `hit` with `shape[t] = AREA_CHAIN`, and its blow is `int(shot.get("chain", 0))`
  (an old save's shot with no `chain` arcs nothing). Delete the kill-and-repeat block at the
  function's tail (the `again_face` loop). The spender's heat is paid at the lay, as today.
- The forecast and the chips follow: `preview_round`, the cryo cash and the HUD read
  `reached_by` and `area_shapes`, so a Shocked foe shows the arc's number when the die is
  dragged over a target. Confirm on the harness; if the feed draws blows by shape, `AREA_CHAIN`
  draws as `AREA_ROW` does (check `ui/` for `AREA_`; today nothing there reads the shapes).

`sim/policy.gd`:

- `attack_score`: delete the kill-chain block (the `uses` walk over `targets_for_face`) and pass
  `1.0` where `uses` went (`heat_cost(sk, ms, f, 1.0)`, `volatile_cost(sk, ms, f, 1.0)`). The
  area loop above it (`for n in sk.reached_by(f, target)` with `shapes`) already values each
  conductor through `damage_outcomes(ms, f, n, -1.0, true, AREA_CHAIN)`, which reads
  `area_number` for the base and the foe's Shocked for the first blow's double.
- `mine_score`: beside the row's and the column's means, the conductors': for every alive
  Shocked foe on the field, `p * minf(2.0 * _area_mean(ms, f, Skirmish.AREA_CHAIN), float(n.hp))`
  (the double written out, since the conductors are Shocked by definition).
- The Shock keyword's own valuation (`shock_cash` and the `SHOCK_WEIGHT` line) stays: a charge
  the arc will spend is worth the arc's blow, which the area loop counts, so nothing is double
  counted beyond what today's strike valuation already does for a Shocked target.

`sim/content_db.gd`:

- Components: `chain` joins the numbered weapon keywords. A component with `chain` in its
  keywords says a positive `chain` number, else the error "<id>: Chain says the number every
  other Shocked foe takes: chain"; a `chain` field without the keyword is refused as `burn`'s
  is; `chain` on an attack with power 0 is refused: "<id>: Chain is a weapon's keyword, an arc
  of a blow; a debuff carries none". Keep the numbered-keyword error texts listing Chain among
  Burn, Cryo, Flak, Spread, Penetrate and Splash.
- Grants (`grant_keyword`): `chain` joins `cleave`, `penetrate` and `splash` in the list whose
  grant must say `number`.

## The content and the records

- `content/components.json`, `arc_fault_cannon`: `"keywords": ["chain"], "chain": 2`; its 4,
  heat 2 and tier one stay (the pricing row: it is read again on the conductor before anything
  moves).
- `content/vocabulary.json`, `chain`: the codex becomes "Keyword with a number, a weapon's.
  Chain 2 also lands 2 on every other Shocked foe on the field, wherever it stands, where the
  target takes the roll: the attacker's bonuses land on that 2 as on the blow, then each foe's
  own statuses and armour, so Shocked doubles it and spends the charge. It reads Shocked and
  never lays it." Then regenerate: `perl -e 'alarm 300; exec @ARGV' godot --headless --path .
  -s tools/export_vocabulary.gd` (docs/vocabulary.md) and `python3 tools/pages/bible_tables.py`
  (the bible's keyword table).
- `docs/rules.md`: the Chain line in the keywords list ("a kill repeats the attack...")
  becomes the rule above in one line; "A blow" item 1 adds "Chain's N on every other Shocked
  foe on the field"; the mine paragraph's Chain clause ("a Chain mine that kills repeats...")
  becomes "a Chain mine arcs its number as laid to every Shocked foe on the field as it lands";
  "Reach" gains "Chain's arcs read no reach". Present tense, no dates.
- The bible's Chain row gains "Built <date>" at its end; the to-do's Chain line is ticked in
  the same commit; `docs/status.md` says so; the hangar republished per the README after the
  content change.

## The tests

In `tests/test_skirmish.gd`, replacing `test_chain_repeats_on_a_kill` and
`test_a_chain_mine_that_kills_its_arrival_repeats_the_attack`; synthetic faces only
(`Face.attack(4, L, [K.CHAIN])` with `.chain = 2`), `_ghoul(hp, armour)` foes, Shocked laid
with `Effects.stack(foe, Effects.STATUS["shocked"], Effects.SKIRMISH, "mech", 1,
Effects.DECAY_NONE)` or by spending a `Face.attack(0, L, [K.SHOCK])` first. Every existing test
stays green (737 on the merged head of 28 October).

1. **Arcs everywhere, reach or not.** Two columns, front and back: the target unshocked in the
   front, a Shocked foe behind a standing front foe (out of Direct reach), a Shocked foe in the
   other front slot. A Direct Chain 2 gun of 4 at the target: the target takes 4; each Shocked
   foe takes 4 (2 doubled) and loses its Shocked; the gun's heat is on the gauge once; the log
   holds "arcs to" twice.
2. **The aimed foe is not a conductor.** Aimed at a Shocked foe beside another Shocked foe: the
   aimed takes 8 and is not arced (one blow on it), the other 4.
3. **No conductor, no arc.** No Shocked foe on the field: the target alone, no "arcs to".
4. **The firer's modifiers ride the arc.** A synthetic passive adding 1 to every blow: the
   conductor takes 6 ((2 + 1) × 2); a passive doubling every weapon blow (the Kite's shape):
   8 ((2 × 2) × 2).
5. **The riders land.** Chain 2 with Burn 1: the conductor gains Burning 1; with Flak 1: Flak 1
   after its blow.
6. **A kill by an arc fires the kill triggers.** `devours = 1` on the gun, a Shocked foe of 3
   HP: it dies to the arc and the firer gains Overcharged 1.
7. **Armour and Breach.** A Shocked foe with armour 1 takes 3; with Breach on the gun, 4.
8. **A Barrier.** A Shocked foe carrying Barrier takes 0, loses the Barrier and its Shocked;
   the log says the shock is spent on the Barrier.
9. **Silenced.** The machine Silenced (`Effects.grant_for_rounds(unit, STATUS["silenced"],
   ...)`): the target takes 4, the Shocked foe nothing and keeps its charge.
10. **A mine.** A Chain 2 mine laid on an empty front slot, a Shocked foe elsewhere; a foe
    steps in at the reinforcement step: the arrival takes the shot, the Shocked foe takes 4
    as the mine lands, the spender's heat on the gauge from the lay alone.
11. **The maps.** `area_shapes(gun, target)` maps the Shocked foe to `AREA_CHAIN` and
    `reached_by` lists it; an unshocked back-rank foe behind a full front is in neither.
12. **The bot.** `damage_outcomes(ms, gun, shocked_foe, -1.0, true, Skirmish.AREA_CHAIN)` has a
    mean of 4; the greedy, offered a plain 4 and the Chain 2 gun with two Shocked foes on the
    field, spends the Chain gun.
13. **Content** (`tests/test_content.gd`): the validator refuses Chain with no number, a
    `chain` field without the keyword, and Chain on a 0 attack; the Arc Fault Cannon validates.
    `test_keyword_cap_is_enforced`'s synthetic component adds `"chain": 1`;
    `test_grant_odd` moves to a keyword with no number (`"value": "shock", "number": 2`) and
    expects the same error; a new grant case `"value": "chain"` with no number expects "says
    the number".

## The read, after landing

- The car bench beside the Dingo's harpoon, and the hot bench: `python3 tools/pricing_run.py
  run chain --parts ladders --benches prairie_dog,goshawk --pieces arc_fault_cannon --seeds
  200` (the records' 27 and 28 October reads of the kill and repeat: 6.7 vanilla points on the
  car, the piece no vanilla matched on the Buzzard).
- A Shock team, the Tesla Gauntlets on the Clydesdale beside the harpoon: `python3
  tools/pricing_run.py run chain_tesla --parts ladders --benches prairie_dog --pieces
  arc_fault_cannon --seeds 200 --set
  'chassis/clydesdale/loadout=["tesla_gauntlets","twin_autoguns","enfilade_beam","ankle_mortar","howitzer","airburst_shell","canopy","incendiary_shells","coolant_jacket"]'`.
- The N is content's placeholder: Ryan's rule is that one conductor breaks even against two
  vanilla spends and two or three pay. The reads go in `docs/measurements.md`; the bible's
  Chain row keeps the reason and the exit, never the run.

## What is not in this brief

Aphelion's Shock and Chain setters (a Spread Shock debuff is the arc's natural partner, since
today's setters shock one foe each): content, proposed in chat first, the to-do's Aphelion
line. The Lammergeier's Arc Fault Cannon lock keeps the keyword as the content says.

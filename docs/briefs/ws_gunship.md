# Brief: the gunship (proposal)

<!-- hangar: {"kind": "chassis", "maker": "wainwright_sutler", "tier": 2, "status": "proposal", "slot": true, "name": "the gunship"} -->

The session finishes the medium gunship whose fitted weapons raise its numbers by their tags,
and settles its overlap with the Clydesdale.

**Status**: proposal with a place, conditioned on tags (the analysis, 14 October); it waited
for the stock pass and the numbers' rescale (Ryan, 21 October: "The gunship might as well wait
for the stock pass and number rescaling, since that's its whole deal"), which landed 22 October,
so its session is free to run. **Maker**:
Wainwright & Sutler. **Proposed tier**: two. **Read first**: `docs/briefs/README.md`;
`docs/measurements.md` (13 October, the gunship's stand-in: its measured table and the recipe);
`docs/roster_analysis.md` section 4; the bible's tags rows (section 7).

## The design (the proposal; Ryan's shape, 13 October)

"Its Ballistic weapons raise its armour and cooling, its Beams its shield and recharge, its
Missiles its move and hull; its Arc weapons raise the others' highest rolls." Built in the
hangar, nothing locked, numbers only, five hardpoints, five of a tag the best at that number,
two-tag pieces the chase. The rows recommended in the proposal (below) are placeholders
measured on a stand-in (`docs/measurements.md`, 13 October).

Ryan's calls of 13 October, as the proposal recorded them:

- **The fantasy**: the Hind-D and Metal Gear's running joke, "a weapon to surpass Metal Gear":
  the overbuilt gunship that becomes whatever its guns make it. It lives in the Clydesdale's
  utility space and, like the Clydesdale, locks nothing. The lore is his to write.
- **Five of one tag make it the best at that number**: what makes it interesting, not shades of
  generalist. Ballistic a brick, Beam a shield wall, Missile the fastest machine; Arc makes a
  striker of the rolled guns beside it. Its other tags (Flame, Plasma, Blade, Melee) raise
  nothing; a weapon wearing two of its four tags raises both, and those pieces are its chase.
- **Four tags, the most Wainwright & Sutler ones**: Metal Gear REX's own kit (Vulcan cannons,
  missiles, a laser, a railgun). Six of the twenty-eight pairs of tags raise two of its rows,
  so a two-tag piece is rare enough to chase; by their own fantasy a railgun or a taser harpoon
  wears Ballistic and Arc, a rocket-assisted shell Ballistic and Missile, a laser-guided
  missile Beam and Missile (Claude's examples).
- **Its only power**: it locks nothing, so the passive carries what other machines' passives
  and locked pieces carry; it is measured against the whole roster, not one machine (the Baboon
  and the Stingray are support machines, weak alone by design).
- **The hangar it is**, over growing in the fight. His test for no clear winner: nothing a tag
  grants feeds that tag.
- **Numbers, never mechanics**: stats, or what reads like them on the die; no rerolls, no new
  rules on any row.
- **The fives and tens are magnitudes**: the rule meant the scale, not the step, so the rows
  can be sized finely; a move is a count of hexes (28 October; the rules).
- **Offence as a raised roll**: a higher top or bottom roll, never a straight damage buff, from
  a tag whose weapons seldom roll. In today's stock every rolled weapon is kinetic and every
  energy weapon flat, so Arc, flat by its pieces, raises the highest roll of the others (the
  Muzzle Velocity Booster's effect, and a railgun's muzzle velocity). The row says "the
  others", so an Arc weapon that rolls takes nothing from it.
- **Cooling, a soft offensive stat**: it sits on the cold tag, Ballistic, since Missile, Beam
  and Arc pieces run hot (missiles make heat), so it feeds the hot guns beside the Ballistic
  ones and never its own. Measured, it pays only on a die of hot pieces
  (`docs/measurements.md`).
- **One machine never dictates the roster**: missiles make heat, an armour cannon stays
  possible, and so on; the gunship takes the components as they come (now the bible's row on
  balancing a component against its tier, section 11).

The rest of the proposal (13 October; Claude's, sized on the stand-in):

- **The rows** (recommended: mid with the riders up; the proposal's placeholders, sized under
  the whole-block shield rule):
  - Ballistic: +3 armour and +4 cooling (five: armour 15, the Polar Bear's today; cooling 25).
  - Beam: +12 shield and +3 field recharge (five: shield 80, the most; recharge 30).
  - Missile: +5 move and +12 hull (five: move 55, the fastest; hull 160, the Badger's).
  - Arc: the others' highest roll 5 higher (the Booster's own number).
  - Flame, Plasma, Blade and Melee: nothing.
- **Engine**: tags on components (the stock pass); a passive that counts the fitted weapons'
  tags and grants static stat modifiers through `sim/effects.gd` (armour, cooling, shield,
  field recharge, move, hull), and Arc's higher top roll as an on-attack ceiling scoped to the
  weapons without Arc; the codex and the hangar show the totals and each weapon's share.
- **The holes**: three lines of rule text, its amounts in the codex, the most the budget holds.
  The bible's tags row lets its count pass (a count every piece of the tag feeds, where nothing
  a tag grants feeds that tag, is no lynchpin). The hangar must show what each weapon fitted
  adds. A weapon counts for the battle once fitted, destroyed or not, as every bonus does. Five
  Beams measured the weakest single tag in a fight, under the old shield rule (below). The
  measures are a stand-in alone, its kits today's pieces until tags exist: teams and whole runs
  can move them.
- **Numbers** (the proposal's placeholders, set under the whole-block shield rule): medium,
  flyer, move 30 (five Missiles make 55); hull 100, shield 20, armour 0, heat 60, cooling 5,
  field recharge 15: low on purpose, the weapons building the rest. Nothing locked. Five
  hardpoints (a d5). Stock: weapons of its four tags once tags exist (the stand-in's first mix:
  the Maxigun, the Slugthrower, the Howitzer, the Enfilade Beam, the Arc Fault Cannon).
- **Set aside along the way** (13 October unless dated):
  - Its Ballistic weapons reaching any foe a Missile struck, every Missile weapon Rapid beside
    it (12 October): a payoff not worth its setup.
  - A bonus per different tag; an offensive upgrade by tag (a keyword per tag), its first-spend
    shape and the switch; a locked Rocket Pods: the shape became Ryan's count by tag, built in
    the hangar, its offence only a raised roll, nothing locked.
  - Growing in the fight (Ryan: the hangar).
  - A free reroll on Arc and straight damage on Plasma (Ryan: a mechanic, where the rows change
    numbers; a raised top or bottom roll instead, from tags that seldom roll).
  - Cooling on Missile (Ryan: missiles make heat); rows on Flame and Plasma (Arc takes the
    roll, and they raise nothing).
  - A promise per row from the stock pass, cold missiles and no armour cannon among them (Ryan:
    one warping machine never dictates the roster of components).
  - Ballistic's armour at every second weapon or capped at 10 (Ryan: the fives and tens are
    magnitudes, not steps); each number kept inside the roster's range (Ryan: five of a tag may
    be the best at it).
  - Six hardpoints (five); every tag read (four, so a piece wearing two is the chase).
  - The Tactical Databank's lowest roll (the alternative to Arc's); maximum heat (filler by the
    measurements, and the hot tags feed on it); a share off damage taken (a multiplier among
    additions); attack range on the map (long guns are pinned while the engagement range may
    change); salvage a kill (the economy is unbuilt); never hunted (a yes or no, which no count
    can scale).
  - In reserve: a falling ladder on armour (5, 4, 3, 2, 1 a Ballistic weapon; a caveat).

## The analysis (14 October)

A place, conditioned on the stock pass's tags. It shares its space with the Clydesdale: two
Wainwright & Sutler machines that lock nothing and carry whatever is fitted, parting on where
the build happens (the fit against the roll). If both stand, the Clydesdale's capacity should
sharpen (its parked levers: ten entries, or two free rerolls). The reshuffle (Claude, 14
October) proposes the Clydesdale at tier one, which would part them by tier. It gives the team
nothing and needs nothing, which is Ryan's call: a gunship is about its weapons.

## Since then

The stand-in's table (`docs/measurements.md`, 13 October) was measured under the old
whole-block shield rule. Under the honest shield rule (decided 14 October) a shield is hit
points, so the Beam row's worth wants re-reading; every cell ran under the old rule, and a
rerun before the honest rule is built still measures it. Ryan, 15 October, wants the
Polar Bear's base armour down for its form changer (`minerva_armadillo.md`), which would move
the Ballistic row's anchor (five at 3 a weapon tie the Polar Bear's armour 15 today).

## Open for the session

1. The proposal's questions: armour 3 or 4 a weapon; a middle at the Clydesdale's level; what
   five Beams are worth over a battle; whether two-tag pieces stay rare once the stock pass
   tags the components.
2. The overlap with the Clydesdale, by tier or by sharpening.

## Waits on

Ryan's design session, which he starts himself (4 November: "very rough right now and might need
to go back to the drawing board"): Claude's first round below (the rescale broke the per-weapon rows)
is input to it, not a round awaiting answers. Played, it wants a hangar that shows what each fitted
weapon adds.

## What the session hands back

A proposal in chat; on Ryan's go, content planned, and this brief retired.

## Claude's first round (3 November)

Proposed in chat; input to Ryan's own session (4 November), which may take the gunship back to the drawing board.

Your shape (13 October) stands: tier two, Wainwright & Sutler, five hardpoints, nothing locked;
its weapons' tags raise its numbers (Ballistic armour and cooling, Beam shield and recharge,
Missile move and hull, Arc the others' top rolls); five of a tag the best at that number;
two-tag pieces the chase. Three things moved under it since the brief was written.

### What moved

1. **The rescale (22 October).** The brief's rows are on the old scale: five Ballistic at +3
   armour made 15, five Beams +12 shield made 80, five Missiles +12 hull made 160. Today tier two
   runs hull 12-40, shield 6-16, armour 0-2 (2 the roster's top, the Wild Boar), move 2-5 hexes,
   cooling 0-2, recharge 4-8; the Booster raises a top roll by 1.
2. **Moves are hexes (28 October).** Move is now a small count, so a Missile's +5 move is +1 hex
   at most.
3. **The stock pass's tags.** Of 43 weapons: Ballistic 20, Beam 5, Arc 5, Missile 4. Pieces
   wearing two of the four: the Overclocked Railgun (Kestrel, tier one) and the Megataser Harpoon,
   both Ballistic and Arc; the third, the Unrestricted Expenditure (Ballistic and Missile), is
   locked on the Musk Ox. So the chase is two pieces, one pair of tags.

### The holes

- **A per-weapon step of 1 is now coarse.** +1 armour a Ballistic weapon makes five armour 5,
  two and a half times the roster's top, against foes' blows of 2 to 6: past "the best at it"
  into a brick most tier-one foes can't scratch. The same for cooling (five makes 5, the top is
  2) and move (+1 a Missile makes base + 5 hexes, the top is 5). Hull, shield and recharge still
  size finely (a few points a weapon).
- **Two rows pay nothing at five.** Arc raises the *others'* top rolls and Ballistic's cooling
  feeds the hot guns *beside* it (your calls, so neither feeds its own tag). With all five
  hardpoints of one tag there are no others: five Arc raises nothing, five Ballistic cools a die
  that runs cold. So "five of a tag the best at that number" holds for Beam and Missile and
  breaks for Arc and half of Ballistic.
- **Equipment wears Arc** (the Klaxon, the Translocator, the Polarity Projector, the Null Field
  Emitter). Since the weapon and equipment words of 26 October, "its Arc weapons" excludes them;
  say if equipment should count.
- **The chase is thin.** Two pieces, both Ballistic and Arc; nothing pairs Beam with Missile or
  Ballistic with Missile for it. Your "one machine never dictates the roster" holds, so I'm not
  proposing pieces for it, only naming it.

### Options (a bench, one line each, with the rule each meets)

- **Per weapon on the fine stats, the coarse one as the five's capstone.** Beam keeps both per
  weapon (+2 shield and +1 recharge: five add 10 and 5, so a base of 8 and 4 lands past the
  tops of 16 and 8); Missile +4 hull a weapon (five add 20) and +1 move at five. Meets "five the best" for both; breaks
  "magnitudes, not steps", since a capstone is a step. My lean for Beam and Missile.
- **Ballistic is the hard one: both its stats are coarse.** Per weapon overshoots either way
  (+1 cooling a weapon makes four Ballistic cooling 5, the top is 2), and a capstone alone leaves
  one to four Ballistic weapons raising nothing. Its options: a point every second weapon (the
  cadence you set aside on the old scale, now the only one fine enough: armour 1, 2 and 3 at
  two, four and five), or one of its stats traded for a fine one. No lean: this is the row the
  rescale broke.
- **Per weapon throughout, the base set low.** Armour +1 a Ballistic weapon from a base of -2
  (armour floors at 0), so five make 3, the best by one. Keeps "no steps"; costs a negative base
  number the codex has to explain, and one to four Ballistic weapons carry a dead first two.
- **Tags counted over the whole kit, equipment included.** More pieces count, so the rows can run
  smaller per piece; it changes your "its weapons" and weakens what a weapon slot means here.
- **Arc and Ballistic's cooling as the mixed build's reward**, said so in the row: they pay only
  beside other tags, by design, and the "five of a tag" promise is Beam's and Missile's.

### Questions only you can settle

1. The coarse stats: Missile's move as a capstone at five (my lean), and Ballistic's armour and
   cooling: a point every second weapon, a low base, or a stat traded for a fine one?
2. Arc and Ballistic's cooling at five: accept that they only pay mixed, or give each a five's
   reward of its own?
3. Does equipment wearing a tag count?
4. The Clydesdale: it now has nine hardpoints and a free reroll a round (its capacity sharpened
   since the brief), so they part on the fit against the roll already. Keep both at tier two, or
   move one?

Once you've picked, I'd measure a stand-in on today's numbers (the 13 October stand-in was the
old scale and the old shield rule) before any content lands.

# Engagement rules: the open discussion

Written 1 October 2026 so Ryan can resume it in a session of its own. Nothing here is decided.
When it is, the decision goes in the bible (section 5) and this file is deleted or marked closed.

## The question

When the movement phase ends, which machines and which packs end up in the same skirmish, and
how does a player see that while planning?

It has to do three things at once:

1. Let a squad of three or four slow machines actually get into a fight together.
2. Stay local: no fight that pulls in units from across the map.
3. Be visible while plotting, and explainable to a new player in one sentence.

## What has been tried

### Cut 1: touching (22 September, Ryan's original)

- A pack that steps beside a grounded machine stops there. That hex is under the machine's
  guns: this is the **zone of control**, drawn as a tinted flower round each machine.
- A fight is the connected group of units that touch, with at least one from each side.
- Flyers control nothing; they join only by ending beside a pack.

**Why it was not enough** (Ryan, 28 September): with move 2 or 3, getting four machines all
adjacent to one moving pack was a placement puzzle the player usually lost. One or two machines
fought; the rest stood a hex away doing nothing.

### Cut 2: engagement range (28 September, what the code does today)

- A fight still seeds only where a machine and a pack touch, so the zone of control holds.
- Then every grounded, non-stealth machine within `Battlefield.ENGAGE_RANGE` (2 hexes) of any
  member joins the nearest group, and this repeats until nothing more joins.
- A dashed tether is drawn from each machine to the nearest pack in its fight, crawling toward
  it, live in the plan preview and again while contacts wait.
- Code: `Battlefield.detect_skirmishes()` in `sim/battlefield.gd`; tethers in
  `BattleMapView._tethers()`.

**Why it is not working** (Ryan, 29 September, from play):

1. **It chains.** Range is measured from the whole group, and the group grows as machines join,
   so a line of machines two hexes apart pulls fights together halfway across the map.
2. **You cannot see who joins until a contact exists.** Nothing on the map shows the range
   until the dry run finds a touch; the tethers appear only then.
3. **It cannot be explained.** "Units touching start a fight, then anything within two of
   anything in it joins, repeatedly" is a nightmare for a new player.

Ryan's framing: "Maybe we're thinking about it all backwards?"

## Ryan's variants (29 September, brainstorming)

1. **Pack engagement zone.** Packs have an engagement zone. Entering it begins an engagement,
   and every ally and enemy inside the zone is drawn in.
2. **Engagement zone plus capture zone.** Only entering the (smaller) engagement zone starts a
   fight; then everything inside the (larger) capture zone is drawn in.
3. **Both sides have zones; overlap triggers.** Allies and enemies each carry an engagement
   zone and anything that overlaps fights. Ryan likes that ranged-leaning machines could join
   from farther away, creating threat. His own doubts: much busier to manage on screen, and an
   open question of what "overlap" means and how to show it when several fights are possible.

Some hybrid is possible too.

## Claude's analysis and recommendation (29 September)

**The chain comes from measuring range from the group.** Measure it from the pack instead and
nothing can grow.

**Recommended: a pack's capture zone** (essentially variant 2, with the engagement zone being
the existing adjacency):

- Keep the zone of control as the stop: a pack that steps beside a grounded machine stops.
- Give each pack a **capture zone**, radius 2, around where it ends the phase.
- Every grounded machine inside a pack's capture zone fights that pack.
- A machine inside two packs' zones merges those two fights. That is the only way fights join,
  so it stays bounded and local.
- **Draw the capture zones all the time**, as violet flowers at each pack's predicted end (the
  pack's intent colour), lit when a machine will stand inside one. Who joins is visible while
  plotting, before any contact exists.
- The tethers become redundant and can be retired.
- A flyer joins only by ending beside the pack, as now.
- One sentence for a new player: *"Your machines stop a pack that steps beside them, and every
  machine within two hexes of it joins the fight."*

**On the other variants:**

- Variant 1 is the same as this if "entering the zone" means the existing stop. If it means
  machines stop when they walk into a pack's zone, that is a new stop rule with its own preview
  problem, and the stop rule already works.
- Variant 3 is effectively a range of four, and much busier to read. What it is really after,
  ranged machines joining from farther away, fits inside the recommendation later as a machine
  stat: **reach**, default 2, drawn as the machine's own ring only when it is selected.

**Holes Claude raised in its own proposal:**

1. A column of four still does not all fight. The pack stops at the front machine; the rear
   ones are three or more hexes back. The decision becomes spread against depth. That may be
   the placement puzzle again, in a milder form.
2. The radius is the one knob (`ENGAGE_RANGE` can carry it). Two may be wrong.

**Also floated and argued against:** offering machines within range at the contact panel and
letting the player choose who commits. It adds a real decision but also a step before every
fight.

## Ryan's position when it was paused

- He confirmed Cut 1 was his original rule and Cut 2 was the fix for squad placement.
- He wanted to review the full history before deciding (this file).
- He chose to pick it up in a separate session.

## Things to decide when this resumes

1. Which rule: the capture zone, one of the variants, or a hybrid.
2. The radius, and whether it is per pack, per machine (reach), or fixed.
3. Whether a merged fight (one machine in two zones) is allowed, or the machine joins only the
   nearest pack.
4. How the zones are drawn without cluttering the map: always, only for packs a machine could
   reach this phase, or only when a pack or machine is selected.
5. What happens to stealth machines and flyers under the new rule.
6. Whether the tethers stay, change, or go.

## Where things live today

- Rule: `sim/battlefield.gd`, `ENGAGE_RANGE` and `detect_skirmishes()`. Four battlefield tests
  cover the current range rule and will need rewriting.
- Map: zones in `BattleMapView._zone()`, tethers in `_tethers()`, contact effect in
  `_contact_effect()`.
- Bible: section 5, the zone-of-control row, the 28 September engagement-range row, and the
  29 September Recommended row with this proposal.
- To-do: the "Decide the engagement rule" line in the Ryan section.

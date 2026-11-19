# Brief: the line frame, the Gundam homage: an offhand that cycles (in session)

<!-- hangar: {"kind": "chassis", "maker": "aphelion", "tier": 1, "status": "session", "slot": true, "name": "the line frame"} -->

The session lands Ryan's kit for Aphelion's Gundam homage: an agile, squishy duelist whose offhand
cycles its beam rifle, beam sword and beam shield, each a rider on what it spends, and a boost pack
that dashes it past the front rank. "The line frame" is a working label; the name and the look are
Ryan's.

**Status**: in session; the kit is Ryan's of 18 and 19 November (below), its open points in chat
with him. **Maker**: Aphelion. **Tier**: one or two ("this one could be 1 or 2"). **Read first**:
`docs/briefs/README.md`; `docs/rules.md` (Rapid, Spread, the strikes, Barrier, Ward, Armoured,
Empowered, the Branches); the Macross's brief (`aphelion_macross.md`), the form shifter beside it.

## Ryan's frame (11 October to 16 November)

- 11 and 12 October: "a Gundam-homage walker"; "Can't be too on point ... as long as it has a
  shield, a handheld rifle, and a beam sword - it's a Gundam." For every Aphelion machine: "They
  use thrusters, sci-fi space-age rockets", never rotors.
- 14 October, its niche: "it combos, it duels other gundams, it usually SLAUGHTERS all the enemy's
  trash without breaking a sweat, and its theme is Beam weapons".
- 16 November, on the first look test: "It needs its own identity. Let's go with a transforming type
  of weaponry for its locked pieces": fists that give way to beam rifles, beam blades "that can turn
  on and off", "a shield made of light", "It cycles through weapon combinations as it idles and as it
  fights", "A small winged backpack that it uses to boost along the ground, not true flight or
  hover", "a homage not a clone". The three look rounds are stills in `docs/looks/` (their text
  `git show e285ff51:docs/briefs/aphelion_line_frame.md`); the model below is the third, reworked.

## The kit (Ryan, 18 and 19 November)

His frame for it, 18 November: "the macross unit truly changes forms. Whereas the Gundam changes
weapons"; "There could be a place for two shifters. The common forms in games is the one you play
towards, and the one you play around": the Macross the one played towards (a strategic shift, its
Transform), the line frame the one played around. The roles he named: "The duelist, a flanker that
isn't the fastest at getting across the map, but once it's there it really holds its own in a
competent player's hands"; the carry; "the utility skirmisher, able to adapt on the fly". And "it
only carries two of its signature equipment at a time". 19 November: "Its an agile duelist, not a
bruiser": squishy, its riders its power. Every number below is a placeholder.

- **The die**: four hardpoints, the main hand (right) a normal mount ("The main hand just has a
  normal mount"), and one locked piece, the Aile Booster: five entries.
- **The offhand**, its passive: the left hand holds the Beam Rifle, the Beam Sword or the Beam
  Shield, and "It cycles after a spend" (19 November: "remove the manual weapon cycle ... That
  closes the barrier-every-turn loop"). Its rider is "a unique (star) effect attached to weapons and
  equipment that target foes", "a unique rider on the current die face, referring to its own
  strikes", and every extra hit carries the entry's riders ("I had intended for everything to apply
  riders").
  - **Beam Rifle**, the soft area: "Each strike also strikes the foe to the right for 2." Half of a
    Spread; on a Spread weapon its neighbour takes both, as Spread and Penetrate stack ("Two spreads
    on the same weapon would combine, but the rifle buff is a different form").
  - **Beam Sword**, the burst: "After each strike, hit the target again for half of the strike's
    damage (rounded down)." Ricochet after every strike rather than once at the end.
  - **Beam Shield**, the defence: "Gain Armoured 2."
- **The Aile Booster**, locked, the lunge: "Rapid. Next weapon strike gains Indirect reach."
- **Two directions**, two steps each:
  - **Duelist I**: Beam Sword to Beam Saber, "After each strike, hit the target again for full damage."
  - **Duelist II**: Beam Shield to Beam Buckler, "Gain Barrier, Ward, and Parry", Parry: "The first
    weapon fired next turn gains bonus damage equal to half of all damage blocked by this machine
    this round (rounded down)"; and the Aile Booster to the Aile Blitzer, "Rapid. Next weapon strike
    gains Indirect reach and ignores armour."
  - **Valkyrie I**: Beam Rifle to Beam Bazooka, "Each strike gains Spread 2 and Penetrate 2."
  - **Valkyrie II**: Beam Shield to Beam Pavise, "Gain 1 Armoured, plus 1 Armoured for every foe
    struck"; and the Aile Booster to the Aile Assaulter, "Rapid. Next weapon strike gains Indirect
    reach. Gain 1 Empowered."
- **Its build-arounds**: soft, one an offhand, and strikes feed two of them: "chasing multi-strike
  pieces would be a thematic fit for an RX-78 homage, which was not a one-strike-wonder machine like
  later machines were. But I might shift things around."

What follows from it as he stated it: the offhand cycles in the order he listed them, rifle, sword,
shield; a reboot spends nothing, so it neither cycles nor rides; a Rapid weapon's second spend rides
the next offhand; the sword's hits again are hits of their own, as Ricochet's are, and set off
nothing more; the Bazooka's Spread adds to a weapon's own; the Pavise counts the foes its own spend
strikes, since the Bazooka is another offhand and never up with it.

**The model** (18 November, on Ryan's "then we'll do line frame" that day, and reworked on his notes
of 19 November; `line_frame` in `tools/lowforge/models_low.py`, `art/models/line_frame.glb`; no
content entry, so it shows in no hangar tab and no fight deals it). The third round, rigged: a waist
the upper body turns and leans on, a head that turns, hips, knees and ankles, shoulders and elbows,
each shoulder gun on an elevation of its own and the pack's four wings on pivots at their roots. On
his notes of 19 November: it stands in an A, its feet wider than its hips, the offhand's foot a
little ahead and the main hand's behind and turned out, the knees soft ("a hint of mecha and a bit
less mechwarrior"); the V-crest is back, round one's two red fins sized to this helm; the calves'
boosters point down and back at about 45 degrees under a cowl, the block behind them gone. The main
hand (right) is a normal mount: its fist kept, fixed, and the mount (hp_1) on its forearm's upper
face, its gun over the fist, the forearm held level at the ready; its rifle, blade and kite gone. The
offhand (left) keeps its weaponry: its fist and rifle on slides along the forearm, the fist drawing
back through the wrist's collar as the rifle runs out from inside. The blade and the kite of light
are made of light (lowforge's `b.beams`): unseen at rest, they appear as an act lights them and go as
it lets them go, a beam lit as the machine is lost stuttering out with its lights; the blade in the
lit tile's white-hot yellow, the kite in the game's shield blue (`amber.shield`), each with its halo.
Four placeholder mounts: the main hand (the Laser Carbine), the shoulders (the Rivet Gun, the Twin
Autoguns) and the helm's pod (the Ankle Mortar). Chosen where his words were silent: the mount on
the forearm's top rather than the fist's; the offhand's foot ahead; the main hand's forearm level at
rest, so its gun reads at the ready; the fist a size up on round three's (his "the hands are small
at rest"). Its acts are the offhand's cycle, each from rest and back, the head leading, the torso a
beat behind and the arms after it, each carried a little past its mark and settling, the weight
onto the front foot as it commits: the offhand's rifle run out beside the main gun, both laid level
and sweeping; its blade lit high outside, a cut across the front and a guard; its kite of light
thrown up across the body with the main gun laid past its edge, a parry's jolt; ready to dash (a
crouch onto the boosters, the wings spread); a look round; its weight shifting over its feet. It
moves by the dash, skimming on its feet in a crouch with every booster lit, the main gun up and the
torso swaying a little over its feet, a walk beside it as a gait option to compare. Its death: the
boosters cut and its knees go, it sits down hard over its planted feet and goes over onto its pack,
its knees up and its arms limp (its middle a little over a quarter of its height off where it stood,
in the A). Set aside on the way: falls onto its back or its face from standing drifted half its
height off its hex, and a bow onto its knees folded its limbs through each other. Lying back, it
falls toward the skirmish's camera, its head and pack at the bottom of its window there. Nothing
fires as its kit would yet: the offhand's held forms and the Aile Booster's act wait on the engine.

## Open, in chat with Ryan

1. Which spends cycle the offhand: every spend, the Aile Booster's own included (its lunge then
   rides the next offhand), or only the spends that carry the rider (Claude's lean).
2. Whether the offhand carries from fight to fight or opens each fight on the rifle.
3. The Parry's "damage blocked": what a Barrier and armour kept off it (Claude's lean), or what its
   shield soaked too.
4. The Parry beside his taste of October ("No reward for being struck that scales with the enemy's
   blows"): it pays half of the blow a Barrier stops, so a boss's biggest blow pays most.
5. The second steps each touch two pieces, the offhand's shield and the Aile Booster, where the
   branches' rule is one locked piece or the passive a step.
6. The name of the booster's buff, a status of its own (his).
7. Its tier, its numbers (squishy; the foes' line's to size), and whether it lands as a planned
   draft, as the Mole did, so the hangar shows it, or dealt.
8. Its look: his read of the model running (the to-do's Judge list).

## Set aside on the way (each with its reason)

- The combo ramp, its first kit (11 to 20 October: a stack a blow, broken by a turn without a
  weapon, paying at thresholds): the reboot breaks it and its cooling and shield payoffs would end
  the reboot's decision, and a count has no order. Free for Aphelion's open slot (Ryan, 19
  November); the briefs README's Aphelion bench.
- Stances as the combo's links (Claude's, 18 November): the Macross is the form shifter, and this
  machine changes weapons, not forms.
- Three locked forearm pieces: "three locked pieces is a lot for a die to hold, especially at low
  tiers" (only tier threes lock three, all three unfinished).
- The pack carrying a third arm through both hands (Claude's): superseded by the offhand alone.
- Swapping on a kill (the kills orbit is crowded, and no shield fits it), on being struck (it
  decides for the player), by spending a hand on itself (a turn, or near free as Rapid, and it
  collides with the shield), by the target picked (every hand all three, so no loadout).
- The manual swap once a turn, a weapon dropped on itself: the barrier-every-turn loop.
- The shield's Armoured a strike (a four-strike gun's Armoured 4, a wall on the right roll), and the
  sword's half rounded up (it doubled a strike of 1).
- Both first steps on the shield: a mixed build's second pick overwrote its first.

## What the session hands back

On his answers: the bible's Aphelion row and the kit's rows; `docs/rules.md` (the offhand and its
cycle, the booster's buff, the Parry); content, planned or dealt; the engine, tested on synthetic
passives; the bot's prices; the texts as drafts for his pass; the model's held offhand forms and the
Aile Booster's act; and this brief retired.

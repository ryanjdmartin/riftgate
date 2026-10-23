# The heroes beyond Final Fantasy: a proposal

Ryan, 15 October: the Priest is fine, but the heroes need to focus on tropes that are not the
series', and the ones already built may convert. Ryan, 16 October: balance the series out a
little, never purge it; the Martial Artist stays for now; the Priest folds into the White Mage,
their kits being much alike; the Necromancer, the weakest homage, is dumped and Sciel takes its
place (in content since 16 October, as the Augur, a working name). The bible's tiers row (section 9) says the finals are homages to the
genre's heroes, spread beyond Final Fantasy, and homage is by archetype (section 1): names and
looks of ours, no series' coinage, no patented mechanic. This file holds the pass until Ryan has
marked it; then its picks become content, art and bible rows, and it retires (git keeps it).
Names are working names, and everything here is Ryan's to move.

A conversion keeps a hero's kit, its rank and its question (what the player's build must
answer); what changes is the trope it homages, its look and its moves' names. The cost still to
come is a forge round for each converted hero (its sprite and its chibi) and content's text.

## The eight built

| Hero | Domain, rank | What it references today (content's fantasy, then its moves) | Where it stands |
|---|---|---|---|
| Warrior | Meadow, front | The classic party's fighter, every JRPG's first hero, a sword the size of the tank; Slash, Cover (planned), Cleave | Keep (Ryan, 16 October: Dragon Quest's hero is ambiguous). |
| Martial Artist | Meadow, front | Final Fantasy's monk, Dragon Quest's martial artist, Chrono Trigger's Ayla (content says a cavewoman with a club; she fights barehanded); Flurry, then Counter, Chakra and Hundred Fists, which are Final Fantasy's monk's (Hundred Fists is Final Fantasy XI's) | Stays for now (Ryan, 16 October). The most Final Fantasy of the generic three, by its moves; if it is ever balanced, its homage leans to Ayla, the cavewoman brawler, its moves renamed in plain words. |
| Thief | Waste, front | Final Fantasy's, Dragon Quest's and Octopath's thief; Mug, Steal, Flee (planned) | **Persona 5's Joker under the plain name** (Ryan, 16 October: still the Thief, for the extra tongue in cheek): masked, a knife and a gun, its calling card the countdown already built, the Steal announced before it lands. Its kit proposed in chat first. |
| Lancer | Waste, front | Final Fantasy's dragoon (the Jump), Legend of Dragoon; Thrust, Jump, Dragon Dive | Keep (Ryan, 16 October: the dragoon is way too iconic to lose). |
| White Mage, now the Cleric | Marsh, back | Final Fantasy's white mage, in the series' white robe with the red trim; Dia, Cure, Holy | Renamed the Cleric (Ryan, 16 October), the homage to every white mage and priest, the bench's Priest folded in (their kits would be much alike); the id stays `white_mage`. The red trim, the one thing about it that is only Final Fantasy's, goes at its next redraw. |
| Necromancer | Marsh, back | Final Fantasy V's necromancer (the Advance version's job) and every bestiary's dark mage; Drain, Raise and Mass Raise, the series' spell names (its Raise revives one's own; ours calls revenants) | Dumped (Ryan, 16 October: the weakest homage); Sciel's hero stands in its place (below). Its art (the sprite, the chibi) came off `art/foes`; the picks keep the sources. Raising the dead stays the Marsh's through its wildlife. |
| Black Mage | Peak, back | Final Fantasy's black mage, the hat; Fire, Fira, Flare | Keep, the spine's own (Final Fantasy is the spine, section 1). |
| Summoner | Peak, back | Final Fantasy's summoner, Golden Sun's adepts, Megami Tensei's demon summoners; Ruin (Final Fantasy XIV's), Diamond Dust (Shiva's; Ryan: fine), Pyroclasm | Keep: its summons are the Norse world's (Skaði, Surtr, Fáfnir), which balance it already. |

The finale's classic four (Knight, Ninja, White Wizard, Black Wizard) are Final Fantasy I's
class changes, and with the spine kept they can stay, the Thief's promoted form following its
homage. Their names are proposed with the promoted forms (the to-do).

## A Clair Obscur hero (Ryan, 16 October)

Clair Obscur's heroes, by archetype: its names are its coinages, so each takes a plain job's
name, as the Thief keeps its own, and every look is ours.

- **Sciel, in the Necromancer's place** (the Marsh, back rank): in (Ryan, 16 October), in
  content as `augur`. Her Foretell is the countdown already built: Omen, a blow named at one
  machine as the round opens and landing two rounds on, at twice her number; below half,
  Harvest, every omen due at once, a countdown of one and `all` on one move (the engine's first
  pairing of the two; tested). Reap is her plain blow, the twin scythe thrown and caught. The
  answers are the countdown's: Suppress holds it, Disrupt breaks it off, a shield goes on the
  marked machine, or the back rank is reached first. Numbers are placeholders.
  **Her weapon is the thing to get right** (Ryan): a twin scythe, one long haft with a curved
  reaping blade at each end, spun and thrown; every take on the picker shows both blades. Her
  look is ours, and Ryan's notes of 18 October on the first round set it: no robes, long coat or
  hood (the first round drew a hooded coat), the blades bigger, both hands on the haft; so a
  sleeveless jerkin of dark green leather over a grey shirt, trousers and boots, bare-headed, the
  bone charms kept, no cards. The second round: fresh takes, image to image from the take he
  called closest (the level hold, 7), and the chibi redrawn the same way; his notes on it (18
  October): the tunics have to go too (3 picked as the base), the blades read as hooks, and the
  chibi's 4 is closest on the weapon. The third round: a short jerkin and trousers, the blades long
  sweeping crescents, image to image from his two picks at strength 0.5 beside fresh takes, one
  set each; Ryan, 19 October: another set, the chibi's 2 "not horrible but can be better". The root
  cause found then: the hero style prompt asks every hero for "ornate armour or robes with gold
  trim and flowing cloth", and the content's own words for what she must not wear (a coat, a
  hood) read to the model as a request, so the fourth round renders her from a prompt of her own
  that names only what she wears (a laced leather vest, shirt, trousers, boots); every take came
  out in it. The double blades still read as hooks or axe heads as often as crescents; the
  chibi's most of all. Ryan, 19 October, on the fourth round: 4 picked for both, "close, definitely
  usable"; the omen in her hand is to be dark, not light, and the lower blade to mirror the upper
  if it can (his guess at the cause: the blade bent to fit the frame); the chibi's upper blade
  carries a second-edge artifact to smooth. The style finding reaches the other heroes: the mages
  all wear the same robes, so a variety pass is on the to-do for later, each hero with a prompt of
  its own. The fifth round (19 October): the omen darkened by the edit model at both sizes, first
  time; then the blades, where Ryan's guess was right: the lower blade is a hook because it sits
  on the frame's bottom edge, and the edit model redraws nothing it has no room for (four
  candidates, the hook unmoved; the chibi's upper-blade artifact smoothed as asked). So the sixth
  gives her room: the pick shrunk onto a taller white canvas, then a close image-to-image pass
  (0.7) whose prompt names two mirror-image blades, the lower one below her boots. It worked: with
  room, the lower blade came out a full crescent at both sizes, first time; at 0.7 the figure
  drifted (hair, costume, face), so the candidates nearest the pick are kept (the hero's 3, the
  chibi's 2) and a tighter pass (0.85) ran beside them, which held the figure and kept both crescents (four each, the hero's 5 and the chibi's 5 the nearest the pick); all on the picker for his pick, his last pick beside them to
  compare. The size worry was Claude's error, found on 19 October by measuring: the cut crops to
  the figure's own box before scaling, so the render's white margin costs nothing, and the new
  picks cut within 3% of the old (a body of about 115 px of 144 against 118; 38 of 48 against 39)
  and wider. Ryan's lever for a bigger body than either is the staff slanted thirty to forty
  degrees, pivoting at its top so the lower blade goes behind her legs: the shaft's vertical run
  shrinks and the figure fills more of the frame. Rendered from her own prompt with the slant
  described (fresh takes; image to image at 0.5 kept the staff upright, so a change of
  composition is a fresh render too), three usable each (a fourth drew two weapons crossed), on
  the picker beside the upright ones. Measured in the cut: the slant takes the hero's body from
  about 115 to about 128 px of 144 and the sprite's width from 79 to 93 of 96, the box's aspect
  now the frame's; the chibi gains little (29 to 31 px wide, the body a point or two), its frame
  being squarer already. Ryan's pick (19 October): the slanted 4, "pretty good", its flaws the
  glowing eyes of the first pick lost, the dark smoke hanging off to the side now that both hands
  hold the staff, and blades that could be much longer now they have the room; the blades first
  (the edit model), the eyes next, the smoke's home his call (Claude's three to choose from: gone,
  wreathing the lower blade, or from her eyes). He asked for the lean he described too, the staff's
  top high on the right and the lower blade behind her legs on the left, a unique silhouette:
  rendered from her own prompt, three usable each size, on the picker beside his pick.
  The sixth round (19 October) answers the three flaws and the lean, one set per question on the
  picker (six sets of her, each fixing one flaw on a different parent, would have been the 13
  October mistake again): the lean (`augur_heroart9`, hero and chibi), three usable each size,
  the hero's 1 the cleanest (both crescents, the smoke off the upper blade); her blades
  (`augur_blades`), three options on one base; her smoke (`augur_smoke`), three homes. What the
  round found. The eyes: a first edit lit her whole face; a tighter one (two small points of
  pale light, no pupils, within her face as it is) landed, and every candidate of the two sets
  carries it. The blades: the edit model gained little (the lower blade sits in the frame's
  bottom-right corner, and a second pass grew only the upper), and room alone did nothing (the
  pick shrunk to 80% and passed at 0.85 came back in the same proportions, the room unused), so
  the long blades are a composite, both heads cut and scaled by a third about their collars and
  the staff lengthened to keep the upper crescent off her head, closed at 0.85, which held them
  every seed. Measured in the cut, the cost: his pick's silhouette already sits at the frame's
  aspect, so a longer weapon widens the box and the body pays, 128 px of 144 down to 103, a
  fifth; and the blades cannot grow inward instead, the upper's tip being fifteen pixels from her
  hair. So the set holds three: the blades as picked, long at a fifth less body, and broader (the
  edit model deepening each crescent's belly within the same span, no cost; two of its three
  came out axe heads and are set aside, and it drifted her eyes red and the steel blue-grey;
  the eyes relit after, while a recolour of the steel greyed the whole staff, shaft and all, so
  it is set aside and the tint stays, to come off at the cut or by a later pass). The smoke's
  three homes, his call, rendered twice each on the eyes-lit base and one of each on the picker
  (gone, wreathing the lower blade, rising from her eyes): two of the six turned her eyes yellow
  and the hotter eye-smoke tinted her whole face, set aside, so a hotter version of the home he
  picks is the next edit. Ryan's picks of the sixth (19 October, afternoon): the lean's 1 is his
  new favourite base, hero and chibi (the chibi's 2), though the rotation went too far, her other
  hand on the staff now and the lower blade boxed on the left instead; from it he wants the smoke
  gone and the top blade flipped to point the other way, its long edge toward the middle of the
  portrait; the blade and smoke sets went unpicked, superseded. The seventh round: the smoke
  erased by hand (it sat over white, the one hand edit that passes) and the flip tried two ways.
  The head reflected across the shaft's axis by hand as a layout for a pass at 0.85 failed at the
  hero's size (the first reflections carried the shaft's own outline, which the pass drew as a
  second prong; a reflection is only as good as its mask and its axis, both measured from the
  brown of the shaft alone); the edit model with the reversed crescent described landed in two
  of six (3, a spearhead with a small inward hook; 9, a full crescent hanging inward, the better),
  the rest drawing the crescent outward again or a plain spearhead. The chibi's axe-shaped head
  resisted the edit model (ten seeds: outward axes, plain spearheads, and one two-bladed head,
  9; a removal of its outer blade took the inner one too), so its flip is the reflection, with
  the mask and axis fixed, passed at 0.85. On the picker as `augur_heroart16` and
  `augur_chibi_heroart16`.
  **Her name** (Ryan: Seer is fine, but a more specific term for a seer of doom or omens?):
  the **Augur**, Rome's reader of omens, the job's own word and Claude's lean, since reading the
  omen and then its landing is her whole kit; the **Harbinger**, the one who announces what is
  coming, death's herald with a scythe, a role rather than a job; the **Haruspex**, the reader
  of entrails, the grimmest and the least known; the **Soothsayer** ("beware the ides of
  March"), a seer of doom in plain English; the **Doomsayer**, plainer still, a touch comic.
  Ryan, 16 October: the Augur.
- **Maelle, as the Duelist**: the easiest homage (Ryan). A fencer whose stance shows on her chip
  and changes with her moves: offensive, she deals and takes more; defensive, she takes less;
  virtuose, the big hit. Stances are statuses, which every number reads already. Not in the
  Marsh, whose boss the Matador asks the same question (a guard, then the flurry). On the Peak
  she would be its first front-rank hero and her virtuose its telegraphed hard hit, the Peak's
  own signature, in the place of the bench's thin Mage.

Maelle stays on the table for the Peak's Mage place, if two are wanted.

## Reraise back on the healer (Ryan, 16 October: consider it)

Settled the same day: Reraise is the promoted Cleric's one move more at the finale, cast on its
allies, the other party members, never itself (Ryan: "appropriately threatening"). In content
planned (`revive_once_ally`, an engine piece to come: today's revive-once is a foe's own), and
Protect left the kit. The reasoning that got there:

The hole: a hero carries three moves and the validator holds it to three (a boss or hero three,
the third a signature opening below half), and the White Mage carries Dia, Cure and Holy; Dia
cannot go, since a foe needs a plain blow for the rounds no special's condition holds, and Cure
is the Marsh's question. So Reraise comes back one of three ways: as the **promoted form's one
move more** at the finale, in Protect's place (Claude's lean: the healer that gets back up once
is the finale's own escalation, and Protect, armour on every foe, is the duller fourth); as a
fourth move on the hero in its final, which bends the three-move rule for one hero (the
promoted forms already carry four, so a four-move final would read as a promoted form early);
or in Cure's place, which it should not. The Zombie Knight carries the same move, so the Marsh
would have two Getting Back Up chips on the field, which is fine: it is the domain's signature.

**The merged healer's name** (Ryan: a combo name?; the Cleric, 16 October): "White Priest" is
no job anywhere. The **Cleric** was Claude's lean: the genre's generic word for the healer (Octopath's Ophilia is a
Cleric, Dungeons & Dragons' healer too), no series' coinage, short on a chip. The **Priest** is
Dragon Quest's and Tactics' word; **White Mage** is Final Fantasy's own coinage, kept if the
spine is to show here as it does in the Black Mage; the **Hierophant** and the **Bishop** are
grander, the Bishop a chess word. The red trim goes at the next redraw whichever name wins.

## The benches

The unbuilt heroes, by domain, and the trope each homages:

- The Meadow's **Tamer**: the monster-collectors (Pokémon, Dragon Quest Monsters), by archetype
  only. It calls the wildlife up and never captures, capturing being one of the patents Nintendo
  sued Palworld on.
- The Waste's **Merchant**, Dragon Quest's Torneko, and **Gunslinger**, Wild ARMs' drifters,
  whose world is a frontier wasteland.
- The Marsh's **Rune-bearer**: Suikoden's True Runes, the Soul Eater whose bearer's blow takes a
  life. The Priest folded into the White Mage (Ryan, 16 October), so the Marsh's bench has a
  place open, which Sciel could take (above).
- The Peak's **Dragon Heir**, Breath of Fire's dragon-blooded hero, massive below half, and
  **Sorcerer**, the genre's dark caster, shadow for fire. Its **Mage**, a second caster's kit, is
  thin beside the Black Mage: Maelle's duelist could take its place (above), or it goes.
- Any domain's **Psychic**, EarthBound's psychic powers by archetype, and **Dancer**, Dragon
  Quest's and Octopath's. The **Blue Mage** is Final Fantasy's own job (it learns the moves used
  against it): a trope from beyond the series for that idea, or it goes.

## The promoted forms' one move more (21 October)

The promoted forms are entries since 21 October (the bible's section 9): massive, armour 2 (5 at the old scale),
their heroes' kits, numbers and names (Ryan, 21 October: the same names; flag it if they feel
thin), and one move more, chosen for two of eight: the Cleric's Reraise on its allies (built)
and the Summoner's Fáfnir (named, its mechanics open). For the other six, one move each, from
the class change's fantasy and on the engine as it stands, so each can land the day it is
marked:

| Promoted form | Its one move more | What it is |
|---|---|---|
| The Warrior (the Knight) | **Sentinel** | Armoured on every one of its own through the next round, cast when one of its own is hurt (the brace on every foe Protect carried): the plain fighter grown into the party's wall. |
| The Martial Artist (the Master) | **Pressure Point** | One blow that switches off the entry the machine shows, aimed at the armed: a nerve struck. |
| The Thief (the Ninja) | **Calling Card** | Named at one machine, it lands two rounds on for twice its blow and corrupts the entry the machine shows: the heist announced before it lands, the countdown the conversion gave Joker. |
| The Lancer | **High Jump** | Leaves the ground for two rounds and lands on every machine for its blow, through the shield: the Jump grown to the whole field. |
| The Augur | **Dispel** | Every buff and store the buffed machine carries unmade (the purge), cast where a machine carries a buff: the reader of fate unwriting it. It would answer section 12's question of a purge's carriers too (a hero's promoted form, by Ryan's reservation of 18 October). |
| The Black Mage (the Black Wizard) | **Meteor** | Gathers a round, then lands on every machine for twice its blow: the genre's last spell. The bosses' slate gives the Behemoth's last act the same name; if both land, one is renamed (Comet is the genre's other word). |
| The Summoner, Fáfnir's mechanics | **Venom** | Fáfnir answers the circle: its breath gathers a round, then lands on every machine for its blow and lays a stack of Burning on each, the wyrm's venom in the Peak's own language, a telegraph and heat. |

A question beside them: the promoted Thief inherits its hero's planned Flee. At the finale a
flee has nowhere to go; a move of its own with Flee's id would take its place, or the promoted
form drops it, or it flees and the finale waits on its return. Ryan's call when Flee is built.

Set aside (each with what set it aside):

- Cover for the Knight: the Warrior's own planned move, which its promoted form inherits the day
  it lands.
- Protect back on the Cleric: Reraise took the place (Ryan, 16 October); it went to the Knight
  here instead, as Sentinel.
- A machine-side poison for Fáfnir: a new status for one move, while Burning already says damage
  over time on our side.
- A venom that switches off the entry every machine shows: the hardest control in the game on
  every machine at once (the same reason Skaði's frost bites rather than freezes).
- Bigger numbers on a promoted form: section 3's rule, a new foe and never an old one with a
  bigger number.

## Questions for Ryan

- The promoted forms' one move more for six of them, and Fáfnir's mechanics (the slate above).
- The Augur's second-round picks on the picker (no coat or hood, the blades bigger), then the cut.
- Maelle as the Duelist on the Peak, in the Mage's place, or not; and the Blue Mage.

## Bench

The ideas set aside, each with what set it aside.

- Dragon Quest's hero for the Warrior: ambiguous (Ryan, 16 October); its heroes are many and
  mostly silent, and "the Hero" is the tier's own word.
- The Valkyrie for the Lancer: the dragoon is too iconic to lose (Ryan, 16 October).
- The Phantom Thief as the Thief's name: the plain name is the joke (Ryan, 16 October).
- The White Mage renamed the Priest: it can be every healer's homage under its own name (Ryan,
  16 October).
- The Black Mage renamed the Mage: the spine keeps its own.
- Maelle's duelist in the Marsh: the Matador, its boss, asks the same question.
- The Seer as Sciel's name: fine, but a more specific term was asked for (Ryan, 16 October).
- The Necromancer kept as the Marsh's dealable third: dumped instead (Ryan, 16 October).
- Hellfire for Surtr: Pyroclasm stays (Ryan, 16 October).
- Protect as the promoted healer's move, and Reraise on itself: Reraise on its allies took the
  place (Ryan, 16 October).
- The Harbinger, the Haruspex and the Soothsayer for Sciel; the Priest and White Mage for the
  healer: the Augur and the Cleric (Ryan, 16 October).
- Chrono Trigger's Lucca for the fire caster: an inventor brings our side's register,
  technology, into the invasion.
- Kingdom Hearts' keyblade wielder: Disney's.
- The Priest as a second healer (the 9 October pitch): it asks the White Mage's question again.

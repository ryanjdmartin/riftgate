# The skirmish's looks

Ryan, 29 October: "I don't love the background of the skirmish screen. It looks amateurish,
distracting, and immersion-breaking, regardless of tileset its trying to replicate. I'd like to
see some different options, not just for the background, but also just general layout shifts
to the skirmish screen to make it seem more battle-like, if we can."

Four grounds and one layout change, built into the game behind switches so they can be played
as well as looked at; today's screen stays the default. Shots of each at the 1080 phone's
layout, beside today's, are on the page (https://claude.ai/artifact/6ZgqskzxdWGpe4XBoMxsoh).
This file retires, git keeping it, once Ryan's pick is a bible row and the others are gone.

## Trying them

- On the phone, a debug build: MENU, SETTINGS, then GROUND and LAYOUT (`Settings.look`). Any
  ground goes with either layout. The pick lasts the session and is never saved, so no test run
  inherits one.
- On the desk, any run: `RIFTGATE_SKIRMISH_BG=vista|field|window|holo` and
  `RIFTGATE_SKIRMISH_LAYOUT=faceoff` (unset, today's screen); `RIFTGATE_TERRAIN=<ground>` puts
  the standalone skirmish on a ground, `RIFTGATE_FOES` on a domain's foes.
- `tools/backdrop_shot.gd` paints the backdrop for every domain and ground into PNGs, headless.

## The options

- **Vista** (layout as it is). The foes' band is the other world as a JRPG battle screen's
  backdrop (`game/ui/battle_backdrop.gd`): a dithered sky, the far land on the horizon and a
  floor in perspective, its palette the domain's (keyed by the bleed in content, a test tying
  the two) and its dress the contact hex's ground (a wood for rough, a range for mountain,
  ruins, a lake at the horizon, a road). The machines' band lays their ground's tile on a floor
  in perspective with the display's hex grid (`game/ui/floor_plane.gdshader`). Every unit casts
  a shadow; an empty slot is a mark on the floor instead of a dark panel. Painted once a fight
  on the foes' own pixel grid (two device pixels a pixel on the 1080 phone), about 30 ms on
  the desk at the phone's size; the meadow at 90% brightness.
- **Face-off** (`field` with `faceoff`). The rows run foes, machines, then the console (log,
  dice, Reroll) and the bottom buttons; one floor runs from the horizon to the machines' feet,
  the other world's under the foes and ours under the machines, meeting at a wandering dithered
  seam with the grid carried across. Each die stays in its machine's column and Reroll far from
  End turn. Costs: a drag to a foe is longer and crosses the machines (they light only for
  shields and vents); "up to the foes, down to my machines" becomes "far to the foes, near to my
  own"; the intent eye sits with the log under the machines, away from the foes it was put
  beside on 23 September.
- **Window** (layout as it is). The vista at 82% inside a feed's frame (brackets, a dithered rim
  into black), the holo floor under the machines: the other world as something CARE is watching.
- **Holo** (either layout; shown in the face-off). No painted ground: a black table at a slant,
  the grid and the ground's contour lines fading where they would be too small to read; in
  today's layout the console sits on dark glass. It drops the Decided "the skirmish is fought
  on the enemy's ground".
- `field` also runs in today's layout, the console on dark glass over the floor; it reads like
  the vista.

Claude's read: the face-off is the one that looks like a battle (the sides on one ground
facing each other, the intent arrows short and off the dice, the dice under the thumb), its
costs to judge on the phone first; the vista alone fixes the background and moves nothing tuned.
No new colour carries meaning: the shadows and the empty-slot mark are black, the grid the HUD
colour as decoration.

## Set aside (each with the rule that set it aside; Ryan's to overrule)

- Drifting clouds, running lava, a rippling lake: nothing else moves while the player thinks
  (the bible's HUD row).
- A red-washed hostile half for the holo table: the semantic colours are fixed, and red is the
  enemy's, which would fight the intent chips.
- The back rank drawn smaller for depth: a foe's pixel lands on whole device pixels (9 October),
  so smaller is blurred or tiny.
- The back rank set half a column over: columns carry rules (Penetrate, a massive foe's column).
- Reroll in the bottom bar to give the face-off's scene more room: Reroll stays far from End
  turn.

## For Ryan

1. Which ground, and which layout?
2. In the face-off, does the longer drag to the back rank sit well under the thumb?
3. Is the meadow too bright behind the foes on the phone?
4. Do the shadows and the floor-mark empty slots stay whatever the pick?

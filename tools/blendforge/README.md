# Blendforge

Mech sprites from a Blender model. You model the mech out of simple shapes; the tool renders
it from every angle the game needs and draws it in the spriter's pixel style, so it sits next
to the primitive mechs without a seam. Blender only supplies geometry: the lighting, the four
tones per material, the crease lines, the outline and the frame fitting are the spriter's own
code, run on Blender's output.

## Run it

```sh
cd ~/Code/riftgate
# a template .blend built from the spriter's Bulwark, to open and look at
tools/spriter/.venv/bin/python tools/blendforge/forge.py example bulwark
# render a model into tools/blendforge/out/<chassis>/ and look at the contact sheet
tools/spriter/.venv/bin/python tools/blendforge/forge.py render tools/blendforge/models/bulwark.blend bulwark
# happy: write the files into art/mechs and re-import
tools/spriter/.venv/bin/python tools/blendforge/forge.py render path/to/anvil.blend anvil --install
godot --headless --path . --import
```

It uses the spriter's virtualenv (Pillow and numpy) and Blender at
`/Applications/Blender.app/Contents/MacOS/Blender`; set `BLENDER=` to point elsewhere. A
render of the nine views takes about half a minute. Output files are the spriter's: three
combat turns at 80x96, six map facings at 24x28, the map strip, and a 4x contact sheet.

## Modelling a mech

Blender does not need to look good. It needs to be the right shapes in the right place with
the right labels.

- **One mech per file.** Put it at the origin, standing on the ground (z = 0), facing +Y
  (the green axis). Any size; the tool scales it to the frame.
- **Simple shapes.** Boxes, cylinders, wedges. The Bulwark template is 43 parts. Rivets and
  panel lines come from the shading and the outline, not from geometry; at 80x96 nothing
  smaller than about a fiftieth of the mech's height survives.
- **One object per part** you might want to move later (turret, arms, legs). Not required
  now, but it makes idle and recoil frames possible without remodelling.
- **Flat shading** is what you want for hard-surface plates (right-click, Shade Flat). Smooth
  shading on a cylinder is fine.
- **Name small parts with "detail"** anywhere in the object name, such as `lens.detail`. They
  are dropped from the 24 px map tokens so those stay clean.

## Materials

A material in Blender is a label on faces: Properties panel, the red sphere tab, New, then
rename it. In Edit Mode, select faces and press Assign to give them a different slot. The
tool ignores the colour you pick and paints by the **name**, so name materials by what the
surface is, not what colour it should be:

| Name | What it is for | Comes out as |
| --- | --- | --- |
| `steel` | armour plates, the body; the default for anything unnamed | mid grey, four tones |
| `steel_dark` | joints, barrels, undercarriage, anything recessed or mechanical | darker grey |
| `livery` | one or two big identity panels: glacis, shoulder pod face, wing | the maker's livery: Halvard deep red, Kestrel cobalt, Orrin & Pike bone white |
| `glass` | cockpit slit, canopy, sensor lens | bright cyan |
| `amber` | warning lights, chevrons, searchlight lens; one or two spots | warm amber |
| `rubber` | tyres, tracks, foot pads, cable bundles | near black, recedes |
| `bore` | the inside of a gun barrel, exhaust holes, muzzle slots | black, reads as a hole |
| `hot` | engine exhaust glow, thruster nozzles | orange-red |
| `white` | bone-white plating where the livery is not wanted | off-white |

Four more names carry a **surface pattern** on top of a base material. The pattern is drawn
in the part's own coordinates, so it sticks to the part in every view and needs no image
model; it is how a plain box reads as a track or a vented deck at 80x96:

| Name | Base | Pattern |
| --- | --- | --- |
| `tread` | rubber | dark bands across the run; the run lies along the part's local Y |
| `grille` | steel_dark | horizontal slats up the face |
| `rivet` | steel | a one-pixel highlight dot every few units across the face |
| `panel` | steel | dark seam lines every few units, both ways across the face |

Patterns use the object's own axes, so apply your rotation before rendering (Object > Apply
> Rotation) or the bands come out at an angle. A track run modelled along X instead of Y gets
its bands the wrong way; turn the part or rotate it 90 degrees and apply.

`livery` is why one file serves every maker: `render ... --maker kestrel` repaints the same
model in cobalt. It is also the plan for player repaints: the maker sets the livery, the
hangar will sell a change of it. Blender's `.001` suffixes are ignored, so `steel.003` is still steel.

If you would rather pick colours than names, that works too: any material whose name is not
in the table is painted from its own Base Color, darkened and lightened into four tones.

## Archetypes: starting points

`tools/blendforge/models/archetypes/` holds sixteen starter silhouettes, one per vehicle
type, so a new mech starts by dragging vertices rather than from an empty scene: tank,
H-tank, hover tank, spider tank, six-wheeled APC, four-wheeled buggy, missile platform,
plantigrade and digitigrade bipeds, tall quadruped, fighter, forward-swept fighter, gunship,
heavy helicopter, fan helicopter, freighter. Each is a few dozen boxes, cylinders and wedges
in the conventions above, already split into parts and tagged with material roles. They are
generic types, not any particular design.

Open one, Save As under the chassis name, reshape it, and render. They are authored in
`archetypes.py` and rebuilt with `forge.py archetypes` (which also renders a review sheet to
`tools/blendforge/out/archetypes/contact.png`), so a Save As is the right move: a rebuild
overwrites the originals. `wedge(..., slope)` there is a box whose top edge on the slope side
drops to the floor; in Blender it is just a cube with two vertices moved.

## Options

- `--fill 0.85` leaves headroom in the combat frame (default fills it).
- `--ppu 1.5` forces pixels per model unit instead of fitting, so two mechs modelled at the
  same scale keep their relative size. The map token follows at the spriter's ratio.
- `--maker` overrides the livery looked up from `content/chassis.json`.

## How it works

`forge.py` writes a view spec, runs Blender headless with `bl_render.py`, and reads back two
images per view: world normals in one, material index and depth in the other, rendered with
flat emission shaders under the Raw view transform so the values are exact. It renders four
times too large, shades every sample with the spriter's light and tone thresholds, keeps the
most common colour per output pixel (so thin slivers vanish instead of sparkling), draws the
spriter's crease rule from the averaged normals and depth, adds the outline, and crops the
frame the way `render_fit` does. `bl_build.py` is the reverse: it turns a spriter model into
a .blend for the `example` command.

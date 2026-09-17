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
| `livery` | one or two big identity panels: glacis, shoulder pod face, wing | the maker's livery: Minerva deep red, Kestrel cobalt, Wainwright & Sutler bone white |
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

## The polish pass: where your job ends and the tool's begins

Your job is massing: which parts exist, their proportions, where they sit, which material
role each carries, and "detail" on the names of things the map token should drop. Boxes and
cylinders are enough; do not round edges, cut panels or add rivets. The pass does that:

```sh
tools/spriter/.venv/bin/python tools/blendforge/forge.py polish tools/blendforge/models/badger.blend
# writes badger_polished.blend beside it; the massing file is never touched
tools/spriter/.venv/bin/python tools/blendforge/forge.py render tools/blendforge/models/badger_polished.blend badger --install
tools/spriter/.venv/bin/python tools/blendforge/forge.py export tools/blendforge/models/badger_polished.blend badger   # art/models/badger.glb for the 3D view
```

What it does, by what a part is:

| Part | Rule |
| --- | --- |
| a plate (any box in steel, steel_dark, livery, white) | bevelled edges, two segments, so every edge catches a highlight band |
| a big face on a livery or steel plate | a recessed panel inset, and a rivet at each corner (`rivet_*.detail`) |
| a track (any rubber box) | rounded ends, cleats across the top and down the outer face, three road wheels on the outer face (`cleat_*.detail`, `roadwheel_*.detail`); the run's material becomes `tread` |
| a cylinder | chamfered caps |

Your own modifiers (an Array of bolt holes, say) are baked first, as they stand. Everything
stays flat-shaded: the toon look needs flat faces flat. Nothing added is thinner than a
model unit, because at the sprite's scale a unit is about a pixel and thinner parts survive
only as stray dots.

If a rule does the wrong thing on a part, name that part so the rule skips it, and say so;
the pass is meant to grow rules, not exceptions. What it does not do yet: joint pistons,
textures or wear (the clean 3D look has none; that is the next question), and it has no idea
which parts are hardpoints, which needs the `hp_<n>` Empties convention from the bible.

## Wear, on the 3D path

`forge.py export` bakes two signals per vertex with Cycles before writing the glTF: ambient
occlusion and pointiness, packed into one colour attribute called `wear` (R and G). The toon
shader's clean look reads them: crevices and undersides take grime, convex edges lose their
paint to bare metal in patches, and a fine noise runs over everything. The pixel look
ignores the bake. `--no-bake` skips it. Tuning lives in `game/ui/mech_toon.gdshader` as the
`grime` and `wear` uniforms and the two noise scales; a mesh without a bake has white vertex
colour, which the shader reads as "no data" and leaves alone.

## Finish on the 2D path

The render is clean but plain. The finish (rivets, panel lines, worn edges, tread, bevelled
highlights) comes from the image model in edit mode, which keeps the render's design and
adds only what it is told to; see "Mechs: the finish pass" in `tools/foeforge/README.md`.
Render here, then `forge.py mech <chassis> --ref <the render>` there, pick, `cut-mech`.
The map tokens stay as rendered; at 24 px the finish would not survive anyway.

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

# Spriter

Renders mech sprites from a few boxes and cylinders, so nobody has to draw pixels. One model
gives every facing at every scale; changing a colour, the camera angle, or the frame size is
one line and a re-render.

## Run it

```sh
cd ~/Code/riftgate
tools/spriter/.venv/bin/python tools/spriter/spriter.py            # every model -> art/mechs
tools/spriter/.venv/bin/python tools/spriter/spriter.py raptor     # one model
tools/spriter/.venv/bin/python tools/spriter/spriter.py --contact-only --out /tmp/look
```

Then in Godot: `godot --headless --path . --import` once, so the new PNGs get import files.
The engine finds the files by chassis id (see `game/ui/sprites.gd`), so nothing else changes.

First-time setup if the virtualenv is missing:

```sh
python3 -m venv tools/spriter/.venv
tools/spriter/.venv/bin/pip install pillow numpy
```

## What comes out

For a model called `bulwark`, in `art/mechs/`:

| File | Size | Use |
| --- | --- | --- |
| `bulwark_combat_front.png` | 48x64 | skirmish screen, drawn at 3x |
| `bulwark_combat_front_left.png`, `_front_right.png` | same | spare three-quarter turns |
| `bulwark_map_strip.png` | 6 frames of 24x28 | battlefield, one frame per facing |
| `bulwark_map_e.png` ... `_se.png` | 24x28 | the same frames, loose, for looking at |
| `bulwark_contact.png` | 4x zoom | everything on one sheet, for review |

Map frames are in the sim's direction order: east, north-east, north-west, west, south-west,
south-east. `Sprites.map_mech(chassis_id, facing)` slices the strip by that index.

## Adding a mech

Add a function in `spriter.py` that returns a `Model`, and register it in `MODELS`. Coordinates
are combat-scale pixels: x to the mech's right, y forward (the way it faces), z up, ground at
z = 0. Keep the whole thing inside about 46 wide and 50 tall for the 48x64 frame (the
three-quarter turns need a little slack at the sides). Aircraft are built on the ground and
then `m.lift(8)` floats them.

```python
def anvil() -> Model:
    m = Model("anvil", "orrin_pike")
    m.box(-11, 11, -12, 12, 16, 30, "steel")        # x0, x1, y0, y1, z0, z1, material
    m.cyl("y", 0, 16, 19, 1.6, 8, "steel_dark")     # axis, cx, cy, cz, radius, length
    m.box(-2, 2, -7, -5, 36, 37.5, "amber", detail=True)   # dropped at map scale
    return m
```

Materials: `steel`, `steel_dark`, `rubber`, `glass`, `amber`, `hot`, `bore`, `white`, and
`house`, which is the maker's colour (Halvard red, Kestrel cobalt, Orrin & Pike bone-white).
Mark small parts `detail=True` so the 24px map frame stays clean. `m.mirror_x(fn)` calls
`fn(-1)` and `fn(1)` for symmetric parts.

## How it draws

One orthographic ray per pixel, camera tilted 22 degrees down for combat frames and 42 for
map frames. Each hit is shaded by how much its surface faces a fixed light, snapped to one of
four tones per material. Flat faces meeting at a right angle, or a big depth jump, get a
crease in the material's darkest tone. A one-pixel outline goes round the whole silhouette.
Map frames are rendered three times too large and each 3x3 block keeps its most common
colour, which is what keeps them from sparkling. Facings are just the model turned about z.

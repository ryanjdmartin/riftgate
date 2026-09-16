# Foeforge

Enemy sprites from an image model running on this Mac, cut down to the frames the engine
loads. Mechs come from the primitive renderer in `tools/spriter/`; enemies are ornate and
organic, which a renderer cannot do, so they come from a model and a post-process.

## Setup

```sh
cd ~/Code/riftgate
/opt/homebrew/bin/python3.12 -m venv tools/foeforge/.venv
tools/foeforge/.venv/bin/pip install mflux pillow numpy
```

The first `generate` downloads the model weights into `~/.cache/huggingface`. The venv and
`tools/foeforge/out/` are gitignored.

## Model

`mflux` runs FLUX on Apple silicon through MLX. The default here is FLUX.2 Klein 4B at 4-bit,
the smallest of the fast models, so a 512x768 candidate takes seconds on an M4 Max. Change
`MODEL` in `forge.py` to try another (`schnell`, `z-image-turbo`, and the rest of
`mflux-generate --help`). Check the licence of whatever you settle on before shipping art
made with it.

## Use

```sh
# four candidates for the ghoul, seeds 1 to 4, plus a contact sheet of the batch
tools/foeforge/.venv/bin/python tools/foeforge/forge.py generate ghoul --n 4

# look at tools/foeforge/out/ghoul/contact.png, pick one, cut it into the engine's frames
tools/foeforge/.venv/bin/python tools/foeforge/forge.py cut tools/foeforge/out/ghoul/ghoul_3.png ghoul
godot --headless --path . --import
```

`generate` builds the prompt from the foe's entry in `content/foes.json` (name, faction,
fantasy, codex) plus a fixed style prefix and a faction colour brief; `--prompt` overrides
it. `cut` keys out the flat background by flood fill from the edges, crops to the figure,
scales it into the frame (48x64, elites 64x96; map tokens 16x16, the colossus 40x40),
snaps every pixel to the faction palette from `docs/sprites-enemies.html`, adds the
one-pixel outline, and writes `art/foes/<id>_combat.png` and `<id>_map.png` plus a 4x
preview next to the candidates. Nothing touches `art/foes` until you run `cut`, so the
sketch grids exported by `tools/sheet_export.py` stay until a candidate beats them.

## Tuning

- A candidate with a busy or shaded background keys badly. Ask for "solid flat pure white
  background" and reject candidates with ground shadows.
- The palette snap is nearest-colour; if a foe reads muddy, add a colour to its faction
  palette on the enemy sheet rather than fighting the prompt.
- Map tokens at 16 px lose everything but silhouette and colour. That is what they are for.

## Mechs: the finish pass

A mech's design comes from its model (Blender through `tools/blendforge/`, or the primitive
spriter), which gives the map facings and a clean but plain combat render. The finish comes
from the model in **edit mode**: the render is the picture being edited, and the instruction
says to keep the silhouette, pose and parts and add rivets, panel lines, worn edges and tread.
Tried on Ryan's Badger, every seed kept the design. Plain image-to-image (`--mode img2img`)
is still there for the record; it redrew the design every time and is not the route.

```sh
# three edits of the blendforge render, then pick from the contact sheet
tools/foeforge/.venv/bin/python tools/foeforge/forge.py mech bulwark --n 3 --ref tools/blendforge/out/bulwark/bulwark_combat_front_right.png
tools/foeforge/.venv/bin/python tools/foeforge/forge.py cut-mech tools/foeforge/out/bulwark/bulwark_front_right_2.png bulwark
godot --headless --path . --import
```

`--ref` is any 80x96 render; without it the sprite already in `art/mechs` is used. The
instruction is fixed apart from the maker's colour brief; `--prompt` replaces it. `cut-mech`
keys the white, fits the 80x96 frame, keeps sixteen colours (eight dulled the finish) and
adds the outline. Re-running blendforge with `--install` puts the plain render back; re-run
`cut-mech` to put the pick back.

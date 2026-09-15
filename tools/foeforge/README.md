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

## Mechs: the hybrid

The renderer in `tools/spriter/` still draws every mech, because it gives six consistent map
facings from one model. For the combat sprite the model refines the renderer's own output:

```sh
tools/foeforge/.venv/bin/python tools/foeforge/forge.py mech bulwark --n 4 --strength 0.3
# pick from tools/foeforge/out/bulwark/contact_front_right.png
tools/foeforge/.venv/bin/python tools/foeforge/forge.py cut-mech tools/foeforge/out/bulwark/bulwark_front_right_2.png bulwark
godot --headless --path . --import
```

`mech` blows the renderer's `art/mechs/<chassis>_combat_<turn>.png` up on white and passes it
as the reference image with the prompt built from `content/chassis.json` and the maker's
colour brief. Strength is how far the model may stray: 0.2 to 0.35 keeps the design and adds
finish; above about 0.5 the render comes back unchanged. Seeds vary a lot, so make a few
and pick. `cut-mech` writes the 80x96 frame the skirmish draws at 2x. Re-run the spriter and
the renderer's sprite comes back; re-run `cut-mech` to put the pick back.

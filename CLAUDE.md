# Riftgate

Godot 4.7 / GDScript. Portrait tactical hex battler for Android. `README.md` explains the layout
and every command; `docs/design-bible.html` records every decision and section 12 is the roadmap.

## Commands

```sh
godot --headless --path . --import                 # first run, and after adding PNGs
perl -e 'alarm 400; exec @ARGV' godot --headless --path . -s tests/run_tests.gd   # tests, about four minutes (watchdog: no `timeout` on macOS)
godot --path .                                     # harness: skirmish screen and map viewer
godot --headless --path . -s tools/export_vocabulary.gd   # regenerate docs/vocabulary.md
perl -e 'alarm 3600; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --seeds 200   # balance report to docs/balance.md (about half an hour); --trace "row|pack|policy|seed" for one fight's log
tools/spriter/.venv/bin/python tools/sheet_export.py      # export enemy grids to art/foes, then --import
tools/foeforge/.venv/bin/python tools/foeforge/forge.py generate <foe> --n 4   # model candidates (mflux, FLUX.2 Klein)
tools/foeforge/.venv/bin/python tools/foeforge/forge.py cut <png> <foe>        # cut one into art/foes, then --import
tools/spriter/.venv/bin/python tools/lowforge/forge.py build <chassis id>...   # ally units, and gate and wall, by code (tools/lowforge/models_low.py), with their rig sidecars (joints, acts), then --import
BPY_PYTHON=<python with the bpy wheel> tools/spriter/.venv/bin/python tools/lowforge/forge.py build <id>   # the same with no Blender installed (a cloud session: python3.11 venv, pip install bpy==5.0.1); tools/lowforge/glbcmp.py old.glb new.glb proves the geometry unchanged
RIFTGATE_ACTS_DEBUG=1 godot --path .               # every idle act back to back, in the skirmish and on the map (=<act name> loops one); tools/act_shot.gd freezes one frame of one act to a PNG
tools/spriter/.venv/bin/python tools/lowforge/forge.py export <chassis id>     # a hand-edited tools/lowforge/models/<id>.blend back to art/models, then --import
tools/spriter/.venv/bin/python tools/lowforge/forge.py shapes                # the five silhouette classes in every maker's metal (art/models/shapes), then --import
godot --path . --resolution 360x640 --position 2000,2000 -s tools/hero_shot.gd -- <chassis> <maker> out.png front 480 480   # one unit large (needs a window)
RIFTGATE_SHOT_H=1616 RIFTGATE_SAFE=80,48 RIFTGATE_SHOT_SCALE=1.5 godot --path . --resolution 360x640 -s tools/screenshot.gd -- <scene> phone.png   # the phone's layout, safe bands and density on the Mac (add --rendering-method gl_compatibility for its renderer)
tools/android.sh                                   # debug APK to the phone over USB (`log` tails it); a crash: ~/Library/Android/sdk/platform-tools/adb logcat -d -b crash
```

Ally art (decided 21 September): the mid-nineties 3D register, built by `tools/lowforge`
from a written brief. A unit is a few hundred flat-shaded facets wearing small generated
tiles in its maker's metal; no hand modelling, no unwrapping. `tools/spriter/.venv` is only
the Python the tools run with.

Always wrap headless Godot runs in a watchdog: a tool script that errors before `quit()` hangs forever.

## Rules

- Declare enum-typed fields and params as `int`. Class-scoped enum types fail to compile when
  class_name scripts load from a headless `-s` runner in Godot 4.7.
- `content/*.json` is data; `sim/content_db.gd` validates it and `tests/test_content.gd` runs the
  validator, so bad content fails the build. Every entry's internal text lives under `design`
  (`fantasy`, `niche`, `holes`, ...: Ryan's pitch, inspiration and homages) and is never shown;
  the validator refuses those keys at the top level. Shown to the player: `codex` (the inspect
  entry), `flavour` (the quote), a passive's `name` and `description`, a foe action's `text`.
  Content ids are Ryan's and may be renamed; runtime code takes defaults from the content,
  never from a hardcoded id. A draft the engine cannot run yet carries `"status": "planned"`
  (a foe action, or a chassis passive): it is kept, not shown, not run, and not validated
  against the engine, so content can be written ahead of code. Tests never assert on a
  specific entry's passive; they use synthetic passives.
- Equipment words (decided 18 September): a **component** is one piece of equipment and
  exactly one entry on the die; a **hardpoint** is a free slot (one `hp_<n>` pin on the
  model); a chassis's **fixed** components are built in and use no hardpoint; an empty
  hardpoint is a blank entry, nothing fills it. Shown text never says "face" (the player
  sees no polyhedron); `Face` is the engine's name for one die entry.
- `sim/` never touches scenes. Everything there runs headless with a seeded RNG.
- Numbers in content are placeholders, not balance.
- Content ideas (makers, chassis, components, foes, names, lore) are proposed in conversation first;
  Ryan tweaks them against his own notes before they land in `content/*.json` or as decided in the bible.
- Numbers are questions, never stored totals: every stat, damage figure and component property
  is read through `sim/effects.gd` (base plus every live source, in one fixed order). A new
  buff, reward or passive is a Modifier with a scope and a source; never write to a stat or a
  component to apply one.
- Keep the fun in mind: prefer one source of randomness, and push back on systems that add no
  decision. Slice and Dice is the touchstone.
- Balance is measured, not guessed (decided 25 September): `sim/policy.gd` plays the skirmish
  headless on a ladder of skill (random, greedy; personas on top) and `tools/balance.gd`
  runs the matrix into `docs/balance.md`. Read bands, not numbers: random beating a pack
  means too easy, greedy losing means a wall, both landing together means no decision.
  Pick share is the component signal. Ryan's play tests decide feel and micro balance;
  the runner decides macro. Never chase a simulated win rate to a decimal.
- When Ryan suggests a rule or a change, look for holes in the argument and discuss them in
  chat before building. A suggestion opens a discussion; it is not a spec. If he reaffirms
  after hearing the holes, build it as he said.
- Judge a visual effect running, never from a still: Ryan does, and a screenshot of a
  breathing mark says nothing about it. Ship a debug switch that fires the thing constantly
  (`RIFTGATE_FEED_DEBUG=1` is the pattern), expect several rounds of small tweaks, and when
  he asks for "faster" or "slower" confirm which direction he means before changing it.
- Lean hotter than seems right on anything the player must see on a phone: every effect,
  tint, line and glow Ryan has judged on a device has come back hotter, thicker or louder,
  never quieter. Start at the exaggerated end and come down.
- Ryan iterates tone and direction as the thing gets built. Adopt each new direction as
  given, and retire the bible lines it supersedes in the same pass rather than leaving two
  truths in the file. On resume the last exchanges are the truth: never re-run a pipeline or
  restore a look the chat has already retired.
- Ryan is colourblind (said 29 September; the type not stated). His colour words are
  suggestions. Never separate two marks by hue alone: give them structure too (an edge,
  dashes, motion, a glyph, a weight). Check a new colour by simulation (the Machado
  protan, deutan and tritan matrices in a few lines of numpy) against every HUD option
  and the enemy red, and pick by the worst case; report lightness and simulated distance,
  not how it looks. Red against the green HUD and violet against the blue HUD are the
  pairs that fold first.
- A phone read arrives as a screenshot. Work it this way: crop and zoom it with nearest
  sampling to see the pixels, reproduce it on the Mac at the phone's layout and density
  (`RIFTGATE_SHOT_H`, `RIFTGATE_SAFE`, `RIFTGATE_SHOT_SCALE`, and
  `--rendering-method gl_compatibility` for its renderer; the README has them), then fix it
  once for every glass rather than special-casing the phone. Several "phone bugs" have been
  layout or arithmetic that the Mac was hiding, not renderer differences.

## Session handoff

Sessions have died mid-flight before. To keep the next one cheap to start:

- Commit after each verified chunk of work, from this folder, with tests green. Do not leave a
  day of work uncommitted.
- Before ending a session, or whenever a large task completes, update `docs/status.md`: what
  changed, what was decided, what is next. Keep it short and replace stale lines rather than
  appending forever.
- `docs/todo.md` is the task list: one line per task, grouped by who moves it. A task that
  lands or dies is ticked or struck in the same commit as the work; a new task goes in when
  it is agreed, not when it is remembered. Status says how things stand; the to-do says what
  is next; the bible says why.
- Record decisions in `docs/design-bible.html` when they are made, not at the end.
- Design canvases under `docs/canvas/` are not watched. Ryan says when one changes.

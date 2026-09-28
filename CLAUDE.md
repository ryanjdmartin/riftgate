# Riftgate

Godot 4.7 / GDScript. Portrait tactical hex battler for Android. `README.md` explains the layout
and every command; `docs/design-bible.html` records every decision and section 12 is the roadmap.

## Commands

```sh
godot --headless --path . --import                 # first run, and after adding PNGs
perl -e 'alarm 240; exec @ARGV' godot --headless --path . -s tests/run_tests.gd   # tests (watchdog: no `timeout` on macOS)
godot --path .                                     # harness: skirmish screen and map viewer
godot --headless --path . -s tools/export_vocabulary.gd   # regenerate docs/vocabulary.md
perl -e 'alarm 900; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --seeds 200   # balance report to docs/balance.md; --trace "row|pack|policy|seed" for one fight's log
tools/spriter/.venv/bin/python tools/sheet_export.py      # export enemy grids to art/foes, then --import
tools/foeforge/.venv/bin/python tools/foeforge/forge.py generate <foe> --n 4   # model candidates (mflux, FLUX.2 Klein)
tools/foeforge/.venv/bin/python tools/foeforge/forge.py cut <png> <foe>        # cut one into art/foes, then --import
tools/spriter/.venv/bin/python tools/lowforge/forge.py build <chassis id>...   # ally units, and gate and wall, by code (tools/lowforge/models_low.py), then --import
tools/spriter/.venv/bin/python tools/lowforge/forge.py export <chassis id>     # a hand-edited tools/lowforge/models/<id>.blend back to art/models, then --import
godot --path . --resolution 360x640 --position 2000,2000 -s tools/hero_shot.gd -- <chassis> <maker> out.png front 480 480   # one unit large (needs a window)
RIFTGATE_SHOT_H=1616 RIFTGATE_SAFE=80,48 RIFTGATE_SHOT_SCALE=1.5 godot --path . --resolution 360x640 -s tools/screenshot.gd -- <scene> phone.png   # the phone's layout, safe bands and density on the Mac (add --rendering-method gl_compatibility for its renderer)
tools/android.sh                                   # debug APK to the phone over USB (`log` tails it); a crash: ~/Library/Android/sdk/platform-tools/adb logcat -d -b crash
```

Ally art (decided 21 September): the mid-nineties 3D register, built by `tools/lowforge`
from a written brief. A unit is a few hundred flat-shaded facets wearing small generated
tiles in its maker's metal; no hand modelling, no unwrapping. `tools/spriter/.venv` is only
the Python the tools run with.

```sh
```

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

## Session handoff

Sessions have died mid-flight before. To keep the next one cheap to start:

- Commit after each verified chunk of work, from this folder, with tests green. Do not leave a
  day of work uncommitted.
- Before ending a session, or whenever a large task completes, update `docs/status.md`: what
  changed, what was decided, what is next. Keep it short and replace stale lines rather than
  appending forever.
- Record decisions in `docs/design-bible.html` when they are made, not at the end.
- Design canvases under `docs/canvas/` are not watched. Ryan says when one changes.

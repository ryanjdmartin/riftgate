# Riftgate

Godot 4.7 / GDScript. Portrait tactical hex battler for Android. `README.md` explains the layout
and every command; `docs/design-bible.html` records every decision and section 12 is the roadmap.

## Commands

```sh
godot --headless --path . --import                 # first run, and after adding PNGs
perl -e 'alarm 240; exec @ARGV' godot --headless --path . -s tests/run_tests.gd   # tests (watchdog: no `timeout` on macOS)
godot --path .                                     # harness: skirmish screen and map viewer
godot --headless --path . -s tools/export_vocabulary.gd   # regenerate docs/vocabulary.md
tools/spriter/.venv/bin/python tools/spriter/spriter.py   # regenerate mech sprites, then --import
tools/spriter/.venv/bin/python tools/sheet_export.py      # export enemy grids to art/foes, then --import
```

Always wrap headless Godot runs in a watchdog: a tool script that errors before `quit()` hangs forever.

## Rules

- Declare enum-typed fields and params as `int`. Class-scoped enum types fail to compile when
  class_name scripts load from a headless `-s` runner in Godot 4.7.
- `content/*.json` is data; `sim/content_db.gd` validates it and `tests/test_content.gd` runs the
  validator, so bad content fails the build. `fantasy` and `question` are internal design fields;
  `codex` and `flavour` are player-facing.
- `sim/` never touches scenes. Everything there runs headless with a seeded RNG.
- Numbers in content are placeholders, not balance.
- Keep the fun in mind: prefer one source of randomness, and push back on systems that add no
  decision. Slice and Dice is the touchstone.

## Session handoff

Sessions have died mid-flight before. To keep the next one cheap to start:

- Commit after each verified chunk of work, from this folder, with tests green. Do not leave a
  day of work uncommitted.
- Before ending a session, or whenever a large task completes, update `docs/status.md`: what
  changed, what was decided, what is next. Keep it short and replace stale lines rather than
  appending forever.
- Record decisions in `docs/design-bible.html` when they are made, not at the end.
- Design canvases under `docs/canvas/` are not watched. Ryan says when one changes.

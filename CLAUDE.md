# Riftgate

Godot 4.7 / GDScript. Portrait tactical hex battler for Android. `docs/rules.md` states the game's
rules as they are now: read it first. `docs/design-bible.html` records every decision and why
(its first row says how to read a row; section 12 holds the questions only Ryan can settle);
`docs/status.md` says how things stand and the order of work; `docs/todo.md` holds the tasks;
`README.md` explains the layout, every document's job and every command.

## Commands

```sh
godot --headless --path . --import                 # first run, and after adding PNGs or a class_name
perl -e 'alarm 400; exec @ARGV' godot --headless --path . -s tests/run_tests.gd   # tests, about four minutes (watchdog: no `timeout` on macOS)
godot --path .                                     # harness: skirmish screen and map viewer
godot --headless --path . -s tools/export_vocabulary.gd   # regenerate docs/vocabulary.md after a vocabulary change
perl -e 'alarm 7200; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --seeds 200   # the balance report into docs/balance.md (about 45 minutes); --trace "row|pack|policy|seed" for one fight's log
perl -e 'alarm 3600; exec @ARGV' godot --headless --path . -s tools/campaign_run.gd -- --runs 40   # whole runs against a plain player into docs/campaign_run.md (two minutes)
```

Every other command (models, foes, sound, screenshots, the phone, the pages) is in `README.md`.

Always wrap headless Godot runs in a watchdog: a tool script that errors before `quit()` hangs forever.

## Rules

- Declare enum-typed fields and params as `int`. Class-scoped enum types fail to compile when
  class_name scripts load from a headless `-s` runner in Godot 4.7.
- `content/*.json` is data; `sim/content_db.gd` validates it and `tests/test_content.gd` runs the
  validator, so bad content fails the build. Every entry's internal text lives under `design`
  (`fantasy`, `niche`, `holes`, ...: Ryan's pitch, inspiration and homages) and is never shown;
  the validator refuses those keys at the top level. Shown to the player: `codex` (the inspect
  entry), `flavour` (the quote), a passive's `name` and `description`, a module's `text.description`, a foe action's `text`.
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
  A maker's profile, its vocabularies and the keywords it leans on are identities, never
  exclusions: design from the piece's fantasy (a spider paralyses, whoever builds it), never
  from a table of who owns what.
- Numbers are questions, never stored totals: every stat, damage figure and component property
  is read through `sim/effects.gd` (base plus every live source, in one fixed order). A new
  buff, reward or passive is a Modifier with a scope and a source; never write to a stat or a
  component to apply one.
- Keep the fun in mind: randomness is one source the player can see and shift (the die, a rolled range,
  a rider's chance on a chip), and push back on systems that add no decision. Slice and Dice is the touchstone.
- Balance is measured, not guessed (decided 25 September): `sim/policy.gd` plays the skirmish
  headless on a ladder of skill (random, greedy; personas on top) and `tools/balance.gd`
  runs the matrix into `docs/balance.md`. Read bands, not numbers: random beating a pack
  means too easy, greedy losing means a wall, both landing together means no decision.
  Pick share is the component signal. Ryan's play tests decide feel and micro balance;
  the runner decides macro. Never chase a simulated win rate to a decimal.
- The bible's register (decided 13 October): a Decided row is a design test (what the player
  feels), a rule the engine runs, or a content call for a named piece; a maker's or a side's
  theme, word or keyword is a Lean, never a rule and never an exclusion. A "never" carries its
  reason and the condition that reopens it, or it is the current state, not a law; a row that
  retires a mechanism names the form that failed and the test it failed, so a new form is free
  to be proposed. Write Ryan's preference at the strength he gave it. A proposal shows the ideas
  a rule killed (a bench, one line each with the rule) so he can overrule the rule; an "out of
  bounds" list in a proposal is his to write, never pre-applied. A cell delta is read at 200
  seeds or as a band; a 30-seed run is a direction and is called one; every run a decision
  cites goes in `docs/measurements.md`, and a row keeps the reason and the exit, never the run.
- Sunk costs never count in design (Ryan, 15 October): finished art, built code or picked
  sprites are no argument against a better design. Name the cost still to come when it
  matters for planning, never as a reason against the change.
- Names carry their proper marks (Ryan, 15 October: his keyboard has none, so fill them in,
  in everything): Skaði, Fáfnir, Ragnarök. Content ids stay plain ASCII. Every font the game
  ships draws Latin-1 (ð, á, ö, þ, æ); Share Tech Mono, the HUD's mono face, lacks the macrons
  (ā, ō, ū), so a name that carries one is checked wherever the mono face shows it.
- When Ryan suggests a rule or a change, look for holes in the argument and discuss them in
  chat before building. A suggestion opens a discussion; it is not a spec. If he reaffirms
  after hearing the holes, build it as he said. It runs both ways: every rule and guideline,
  these included, is open to debate for a good reason (bible section 2), so argue for changing
  one in the open rather than designing around it.
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

- One folder per branch (decided 5 October). `~/Code/riftgate` stays on `main`. A session that
  needs another branch (a cloud session resumed on the Mac for its tools, most often) works in
  its own worktree, `git worktree add .claude/worktrees/<name> <branch>` and EnterWorktree with
  that path, never by switching the main folder's branch under whoever is using it.
  `.claude/worktrees/` is excluded in `.git/info/exclude`. A worktree has no `.godot` import
  or git-ignored tools: run `--import` there before Godot, and call the venvs by their path in
  the main folder. Remove the worktree once its branch is merged.

- Commit after each verified chunk of work, from this folder, with tests green. Do not leave a
  day of work uncommitted.
- Before ending a session, or whenever a large task completes, update `docs/status.md`: what
  changed, what was decided, what is next. Keep it short and replace stale lines rather than
  appending forever.
- `docs/todo.md` is the task list: one line per task, grouped by who moves it. A task that
  lands or dies is ticked or struck in the same commit as the work; a new task goes in when
  it is agreed, not when it is remembered. Status says how things stand; the to-do says what
  is next; the bible says why.
- Record decisions in `docs/design-bible.html` when they are made, not at the end. A rule that
  changes is edited in place in `docs/rules.md` (present tense, no dates) in the same commit as
  its bible row. Both say what is true now: a superseded line is rewritten, never appended to,
  and neither keeps a changelog (git and `docs/status.md` carry the history).
- Before proposing a change, read what `docs/rules.md`, the bible and the code already say about
  it. A proposal that re-opens a settled point, or states one wrongly, costs Ryan a correction;
  when the records cannot settle it, ask.
- One home for each thing, so nothing drifts: the order of work is `docs/status.md`'s "Next,
  in order", kept at every handoff; a question only Ryan can answer is the bible's section 12;
  a task is `docs/todo.md`; a run a decision cites is `docs/measurements.md`; a proposal is
  `docs/<maker>_proposal.md` until its evaluation, then a design in progress is its brief in
  `docs/briefs/` until its session lands; each retires (git keeps it) once its decisions are
  rows and content. Never the same item in two files, and no row carries a conversation: a long
  Open row is a paragraph and a pointer to its proposal or brief.
- Design canvases under `docs/canvas/` are not watched. Ryan says when one changes.

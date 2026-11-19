# Riftgate

Godot 4.8 (4.8-beta2 until 4.8 ships, for its MSAA fix) / GDScript. Portrait tactical hex battler for Android. `docs/rules.md` states the game's
rules as they are now: read it first. `docs/design-bible.html` records every decision and why
(its first row says how to read a row; section 12 holds the questions only Ryan can settle);
`docs/status.md` says how things stand and the order of work; `docs/todo.md` holds the tasks;
`README.md` explains the layout, every document's job and every command.

## Commands

```sh
perl -e 'alarm 600; exec @ARGV' godot --headless --path . --import   # first run, and after adding PNGs or a class_name
perl -e 'alarm 400; exec @ARGV' godot --headless --path . -s tests/run_tests.gd   # tests, about four minutes (watchdog: no `timeout` on macOS)
godot --path .                                     # harness: a battle, a skirmish, a saved battle and the quick campaign
perl -e 'alarm 300; exec @ARGV' godot --headless --path . -s tools/export_vocabulary.gd   # regenerate docs/vocabulary.md after a vocabulary change
python3 tools/pages/bible_tables.py                       # the bible's buff, debuff and keyword tables, after any content change
perl -e 'alarm 36000; exec @ARGV' godot --headless --path . -s tools/balance.gd -- --seeds 200   # the balance report into docs/balance.md (hours on one core; about two in four parts, the README's --part and --merge); --trace "row|pack|policy|seed" for one fight's log
perl -e 'alarm 3600; exec @ARGV' godot --headless --path . -s tools/campaign_run.gd -- --runs 40   # whole runs against a plain player into docs/campaign_run.md (about four minutes)
```

Every other command (models, foes, sound, screenshots, the phone, the pages) is in `README.md`.
On the Windows desk machine (since 19 October) they all run as written from Git Bash; from
PowerShell, `& 'C:\Program Files\Git\bin\bash.exe' -lc '<command>'`. The README's Running
section says what is set up there and what cannot run (foeforge's renders need the Mac).
There the Claude app is a packaged Windows app: anything a session writes under `AppData`
(`AppData\Local\Programs` excepted) goes to a private copy that Ryan's own shells never see,
though the session's own commands do. Install shared tools elsewhere, and check from a
terminal tab, which sees what his shells see.

Always wrap headless Godot runs in a watchdog: a tool script that errors before `quit()` hangs forever.

## Rules

- Declare enum-typed fields and params as `int`. Class-scoped enum types fail to compile when
  class_name scripts load from a headless `-s` runner (seen in Godot 4.7, not rechecked since).
- `content/*.json` is data; `sim/content_db.gd` validates it and `tests/test_content.gd` runs the
  validator, so bad content fails the build. Every entry's internal text lives under `design`
  (`fantasy`, `niche`, `holes`, ...: Ryan's pitch, inspiration and homages) and is never shown;
  the validator refuses those keys at the top level. Shown to the player: `codex` (the inspect
  entry), `flavour` (the quote), a passive's `name` and `description`, a module's `text.description`, a foe action's `text`.
  Content ids are Ryan's and may be renamed; runtime code takes defaults from the content,
  never from a hardcoded id (a fallback model, maker or faction is content's first). Code
  names an id only to key an asset to a maker or a domain (a metal, a sound, the gate's
  Arsenal iron); tests tie the metal and sound tables to content, so a rename fails the build
  until they follow. A draft the engine cannot run yet carries `"status": "planned"`
  (a foe action, a passive, a component or a vocabulary term): it is kept, not shown, not run, and not validated
  against the engine, so content can be written ahead of code. Tests never assert on a
  specific entry's passive; they use synthetic passives.
- Shown text is Ryan's to write (9 November: "I need to get a strong foothold on content I've
  written myself, so that you can do a better job of mimicking my intended writing style"). The
  hangar's Text tab lists every text the player reads (`tools/hangar_text.py` is the one
  definition of what is shown, where and whether any screen draws it); `docs/hangar/text.json`,
  the ledger, says which he signed as his own and which drafts he passed, and a text it does
  not name is a session's draft. Before drafting any shown text, read `docs/voice.md` (his own,
  by kind and by voice), the kind you are writing and its maker's or domain's group first, and
  write the draft to sit beside them. Never sign a text for him and never edit the ledger by
  hand: the fold writes it from his marks. A signed text changes only when its rule does, as
  little as the rule needs, and is named in the report (the page shows it to him as changed);
  a rename moves the slot's ledger line with the id (`python3 tools/hangar_text.py --check`
  says when one is left behind). A new key that holds shown text gets a slot there.
- Kit words (decided 18 September): a **component** is one piece of kit and exactly one
  entry on the die; a **hardpoint** is a free slot (one `hp_<n>` pin on the model); a
  chassis's **fixed** components are built in and use no hardpoint; an empty hardpoint is a
  blank entry, nothing fills it. Shown text never says "face" (the player sees no
  polyhedron); `Face` is the engine's name for one die entry. A component is a **weapon**
  (it deals damage), a **shield**, a **vent** or **equipment** (a buff or a debuff, dealing
  none; Ryan, 26 October), so text never says "damaging weapon": a trigger is damaging a foe
  with a weapon, hitting a foe with a weapon, or hitting a foe with a weapon or equipment.
  The engine's `Kind.ATTACK` is a weapon and a debuff alike (`is_weapon()`, `is_attack()`).
  The refit pass's model (Ryan, 9 November; landed in content 10 November on his "start with
  the minimal swaps"; `docs/briefs/refit_pass.md`): shields and vents have left the die, so a
  dealt component is a weapon or equipment, and the shield and the heat come back by a reboot
  alone (the next rule: no chassis regenerates or cools); the slottable shields and vents are
  planned drafts nothing deals, two machines are back in design (`"status": "planned"` on the
  chassis), and the engine still runs the four kinds for the locked pieces that are one.
- The reboot is the rule of the shield and of heat (Ryan, 13 November: "This is
  fundamental, I don't want it to get skipped by other sessions"; folded into the game on 15
  November, on his "Go ahead on the fold and build"): `docs/rules.md` has it (The reboot), and
  `docs/briefs/refit_pass.md`, section 22, his rules, his rulings and the spec. Read both
  before designing, pricing or reading any machine, component, module or foe. Nothing
  regenerates or cools by itself; a machine that has spent nothing may give its turn to a
  reboot, bare that turn, cold and whole the next; heat past the maximum stays and burns hull
  every turn; a shield at nothing is broken and gains none until the reboot. No chassis
  carries a regen or a cooling (the validator refuses both keys). Tier one's foes are sized
  against it, its elites and bosses for a squad without the Barrier basic (17 and 18
  November); tiers two and three are still the ones sized against a shield that refilled,
  and the numbers pass sizes them (`docs/briefs/numbers_pass.md`; its line alone moves a
  balance number, the status's Start here). A piece that leans on regen, cooling, a shield gain or a vent says so. His
  expectation, no strict rule ("I don't want to make a strict rule about anything"): what
  grants regen, cooling, flat shield or flat heat reduction is part of a kit or a locked
  piece, or gated behind a synergy ("they should be something special"); and a shield spend
  may not be standard fare ("it's so expensive").
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
  headless on a ladder of skill (random, blind, greedy and a two-round planner; personas on top) and `tools/balance.gd`
  runs the matrix into `docs/balance.md`. Read bands, not numbers: random beating a pack
  means too easy, greedy losing means a wall, both landing together means no decision.
  Pick share is the component signal. Ryan's play tests decide feel and micro balance;
  the runner decides macro. Never chase a simulated win rate to a decimal.
- A fundamental is reasoned as a system before it is measured (Ryan, 13 November, of the
  shield: "our enemies aren't set up to threaten that type of defense"; "It's all part of the
  same system, not just how hard the foes hit, but HOW they hit that matters. Ergo we need to
  be thinking theoretically and critically about the system as a whole and how it fits
  together, and build simple models perhaps, before slamming it against the whole game as it
  stands"). For a rule over the shield, the die, heat or targeting, lay out first who it
  protects, how, what threatens it and the counterplay on both sides, with a small model apart
  from content where one helps (`tools/budget_model.py` is the pattern), and name the foes it
  would need. The runner's read on today's content says what today's foes do against the
  rule, never whether the rule is right: they were built for another.
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
  The bible is "primarily used for" session context (Ryan, 23 October), so a row holds the
  decision, its reason, its exit and his words where they set its strength; how a thing is
  built is the code's and `docs/rules.md`'s, a placeholder number is content's, a design
  session's rounds are its brief's (the bible's first row).
- Sunk costs never count in design (Ryan, 15 October): finished art, built code or picked
  sprites are no argument against a better design. Name the cost still to come when it
  matters for planning, never as a reason against the change.
- Names carry their proper marks (Ryan, 15 October: his keyboard has none, so fill them in,
  in everything): Skaði, Fáfnir, Ragnarök. Content ids stay plain ASCII. Every font the game
  ships draws Latin-1 (ð, á, ö, þ, æ); Share Tech Mono, the HUD's mono face, lacks the macrons
  (ā, ō, ū), so a name that carries one is checked wherever the mono face shows it.
- Canadian/British spelling everywhere (Ryan, 17 November: "yes we're using Canadian/British
  spelling everywhere"): armour, colour, centre, tunneller, in shown text, content, docs and
  comments alike. Engine and library names keep their own spelling (Godot's `Color`).
- When Ryan suggests a rule or a change, look for holes in the argument and discuss them in
  chat before building. A suggestion opens a discussion; it is not a spec. If he reaffirms
  after hearing the holes, build it as he said. A consequence that follows from a rule as he
  stated it is no hole and no question: build it and name it in the report (Ryan, 7 November:
  "all logically fall out with the way I stated the mechanics without ever being a question");
  a hole is where his words give two answers or none. It runs both ways: every rule and guideline,
  these included, is open to debate for a good reason (bible section 2), so argue for changing
  one in the open rather than designing around it.
- A one-off exception proposed for balance is a symptom (Ryan, 18 October): before proposing
  one, look for the root cause that makes it seem reasonable and fix that, in the open; a
  passive breaking a rule for its design is a different thing (bible section 7).
- A rule leaves the engine with its last piece (Ryan, 12 November, on seven rules that had lost
  theirs in five days and stayed: "Yeah go ahead and fix it"): a rework that takes a rule's last
  carrier cuts the rule in the same pass, its engine path, its validator check, its term and
  glyph, its bot weight, its tools' rows and the tests of the rule itself, and moves a test that
  only used it to observe something else onto a synthetic piece. Nothing is parked as a rework's
  "leavings". `tests/test_leftovers.gd` holds it: an effect kind, a trigger, a die entry's key or
  a keyword that no piece prints (a planned draft counts as a piece) fails the build until it is
  cut, or listed there with what it is: a step of the one pipeline or of the trigger table (the
  general path, no piece's rule), a rule a brief's settled answer names, or a field the engine
  sets itself. "It may be wanted some day" is no reason: a piece that wants a cut rule back has
  it built then, and git keeps the old form.
- Content slated to change waits for its own session (Ryan, 9 November: "Don't propose issues
  with content slated to change. We're basing decisions around designs that aren't finished"): a
  piece whose rework or design session is pending (the to-do's design sessions, a brief) gets no
  question and no proposal from other work; build around it as it stands and leave it alone.
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
  suggestions. Compose a red or an orange from red and green alone, never blue, brighter and
  darker included (Ryan, 29 October: moving the blue too is what made the reds hard to
  judge); past pure red the green steps 30, 40, 50 and 60 are each distinct to him, and past
  about #ff8200 an orange reads as yellow or green; even a lighter, less red orange can read as
  green, which is good's colour, so heat leans red (Ryan, 30 October). Never separate two marks
  by hue alone: give them structure too (an edge, dashes, motion, a glyph, a weight). What fails is a
  colour over its ground, never two UI colours apart, since every mark carries an icon
  (Ryan, 30 October): check a new colour by simulation (the Machado protan, deutan and
  tritan matrices in a few lines of numpy) against the grounds it is drawn on (the field's,
  the map's, a chip's plate), pick by the worst case, and report luminance contrast and
  simulated distance against them, not how it looks. A debug build's Settings → COLOURS sets
  the colours that carry a meaning and the HUD presets (`ColourTuner`); Ryan tunes there and sends its COPY text (`KEY #rrggbb`
  lines) for the picks to land as the defaults. These rules are for what carries gameplay information: an effect
  that carries none (a weapon's muzzle flare, a shot's tracer) takes the colour that makes sense,
  unchecked and never on the tuner (Ryan, 2 November: "Not worried about colourblind issues for
  things that carry no gameplay information like weapon effects. Choose colours that make sense, I
  don't need to tweak them").
- A phone read arrives as a screenshot. Work it this way: crop and zoom it with nearest
  sampling to see the pixels, reproduce it on the desk machine at the phone's layout and density
  (`RIFTGATE_SHOT_H`, `RIFTGATE_SAFE`, `RIFTGATE_SHOT_SCALE`, and
  `--rendering-method gl_compatibility` for its renderer; the README has them), then fix it
  once for every glass rather than special-casing the phone. Several "phone bugs" have been
  layout or arithmetic that the Mac was hiding, not renderer differences.

## Session handoff

Sessions have died mid-flight before. To keep the next one cheap to start:

- One folder per branch (decided 5 October). The desk machine's folder stays on `main`:
  `C:\Users\jam82\Desktop\Code\riftgate` on the Windows PC since 19 October (`~/Code/riftgate`
  on the Mac before it). A session that
  needs another branch (a cloud session resumed on the desk machine for its tools, most often) works in
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
- The documents a session starts from stay short (Ryan, 17 November, after they had grown to
  hold every earlier form of the game: "I don't feel like it's necessary to be wading through
  all of that context for new sessions when they're reading"). The status says how things
  stand in about three hundred lines, with the latest test count alone; a to-do line is a
  line, and a ticked one leaves the file; a brief or a proposal holds what is live and open,
  and a section the game has left is a stub with its place in git. A decision's history is
  its bible row's and git's. An earlier iteration of the game is never described where a
  session starts reading.
- Check for a newer Godot every two weeks (Ryan, 30 October: "check for godot updates
  periodically"): when the Godot line in `docs/status.md`'s Start here is dated two weeks back
  or more, read `github.com/godotengine/godot-builds/releases` (every build, pre-releases
  included) and date the line again. A newer build goes to Ryan with what it fixes or changes
  for the game (the Compatibility renderer, Android, GDScript, the importer); the move is his
  call, since it costs the desk's install and the phone's export templates (4.8 stable is
  already agreed: the to-do).
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
  `docs/<topic>_proposal.md` until its evaluation, then a design in progress is its brief in
  `docs/briefs/` until its session lands (Ryan corrects briefs in the hangar's Designs tab, and
  a design session folds those in first: the briefs README); each retires (git keeps it) once its decisions are
  rows and content. Never the same item in two files, and no row carries a conversation: a long
  Open row is a paragraph and a pointer to its proposal or brief.
- Design canvases under `docs/canvas/` are not watched. Ryan says when one changes.
- Ryan's writing on the hangar's Text tab waits in the page's `text` collection. A session that
  touches shown text, or republishes the hangar, folds it in first (`tools/hangar_text.py
  --fold`, the README's commands): his words into content, his marks into the ledger, his notes
  answered in the work.
- The quick campaign is an experiment, not a feature (Ryan, 28 October): no decision reads its
  runs and no balance call cites them, until he says that changes. It always follows the main
  content and code, one code tree for both modes (Ryan, 7 November: "The experiment portion is
  in regards to maintaining a seperate balance matrix. I don't want to keep two seperate code
  trees for both modes, not until we have to"): its fights are built by the battle's own
  builders, never a copy of them.

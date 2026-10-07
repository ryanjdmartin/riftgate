"""Jenny's lines: the console's voice as a system, proposed (Ryan, 7 October). She is infrequent
and surprising: many phrases on many hooks, each hook firing a line only sometimes, with space
between lines so she never rattles off several at once.

The system (for sound.gd when it lands):

  chance      each hook has a chance that a trigger says a line at all; information hooks (a
              machine lost, a component damaged or destroyed, a loss) say one every time, since
              that is actual information; victory and the skirmish opening say one every time
              too (Ryan: common moments, obvious ones).
  spacing     one line at a time, never overlapping, and a gap of SPACING seconds between
              lines; a line that waited longer than STALE seconds is dropped unsaid, except an
              information line, which waits its turn.
  variety     a hook draws from its pool without repeating until the pool is spent (a shuffle
              bag per pool).
  personality the rare layer: a line that fires has a PERSONALITY chance of being replaced by
              one from the hook's slang pool, where one exists, as if the machine were learning
              from its users or waking up; the fourth wall breaks here and nowhere else. She is
              Irish, so her sentences may run Irish ("back to hell with you").
  register    CARE's: terse, military, utilitarian, soulless; the personality layer breaks it.

Ryan's second pass on the first draft (7 October): his own lines were flavour, not verbatim;
the kill-shot hook folds into a foe defeated; the gate's two hooks are one; "neutralised" was
everywhere and is rare now; the buff hook wants a section of its own per keyword, and heat and
venting are a gold mine not yet mined (a to-do); refuse's references depend on where the
trigger lands. A line is a string, or a (shown, spoken) pair where the synthesiser needs the
spelling changed to say it right ("tear" as in tare).

Rendered through the decided chain (Jenny, mid, slowed a third, plosives tamed) at -14 dB on
the phone. Every line in every pool is rendered, so each word can be judged.

    tools/spriter/.venv/bin/python tools/soundforge/voice_lines.py          # into out/fx
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import fx_sketches as X  # noqa: E402
import voice_sketches as V  # noqa: E402
import piper_voices as P  # noqa: E402

SR = F.SR
PREFIX = "line_"
SPACING = 6.0        # seconds between lines
STALE = 2.0          # a non-information line older than this is dropped unsaid
PERSONALITY = 1.0 / 15.0

# hook: (chance a trigger says a line, information?, normal pool, personality pool)
HOOKS = {
    "die_spent": (1.0 / 6.0, False,
                  ["target locked", "weapons free", "engaging", "firing solution set", "hostile acquired", "extreme prejudice authorised", "discharging weapon", "light them up", "going ballistic"],
                  ["say hello", "eat this"]),
    "foe_down": (1.0 / 4.0, False,
                 ["target destroyed", "contact down", "lethal force applied", "bogey down", "terminal solution", "target removed", "threat eliminated"],
                 ["get wrecked", "mopping up trash", "that one's done", "delete", "sprite deleted", "power overwhelming", "next"]),
    "foe_down_undead": (1.0 / 3.0, False,
                        ["undead presence cleared", "bone count reduced", "re-interred", "the dead are quiet"],
                        ["and stay dead this time"]),
    "foe_down_demonic": (1.0 / 3.0, False,
                         ["demonic presence eliminated", "infernal unit purged", "hellspawn removed"],
                         ["back to hell with you", "knee deep"]),
    "foe_down_eldritch": (1.0 / 3.0, False,
                          ["unknowable horror purged", "paradox resolved", "sanity restored", "anomaly resolved"],
                          ["thank goodness", "anxiety levels reduced", "that was not supposed to exist"]),
    "buff": (1.0 / 6.0, False,
             ["shield up", "buff applied", "armour online", "overcharge engaged", "unit is tanking", "saving throw granted"],
             ["big heals", "aggro redirected"]),
    "heat": (1.0 / 6.0, False,
             ["venting", "heat sink engaged", "cooling", "thermal load falling", "reactor within limits"],
             ["it's getting hot in here", "hot hot hot"]),
    "machine_lost": (1.0, True,
                     ["machine lost", "unit destroyed", "pilot ejected, machine lost"],
                     []),
    "component_damaged": (1.0, True,
                          ["component damaged", "hardpoint hit"],
                          []),
    "component_destroyed": (1.0, True,
                            ["component destroyed", "hardpoint lost"],
                            []),
    "resolve_all": (1.0 / 2.0, False,
                    ["all units committed", "formation committed", "squad committed", "advancing line"],
                    ["get 'em, boys", "charge!", "rock and roll", "outstanding"]),
    "resolve_move": (1.0 / 3.0, False,
                     ["orders received", "in transit", "moving out", "proceeding", "coordinates received", "moving to intercept", "hostiles advancing", "incoming", "contact predicted"],
                     ["stay on target", "sounds fun", "let none survive", "your time has come", "evil draws close"]),
    "contact": (1.0 / 2.0, False,
                ["combat imminent", "contact", "hostiles in range"],
                ["showtime"]),
    "engage": (1.0 / 2.0, False,
               ["engaging", "feed acquired", "taking the feed live"],
               [("rip and tear", "rip and tare"), "battle music initiated", "so it begins"]),
    "boss": (1.0, False,
             ["primary hostile identified", "priority target, engaging", "boss class contact"],
             ["oh, that's a big one", "well, that's new", "that's a lot of hostile", "big lad"]),
    "gate": (1.0 / 2.0, False,
             ["gate under attack", "gate taking damage", "gate under threat", "gate integrity falling", "they're breaking through"],
             ["they're in the walls"]),
    "flattening": (1.0 / 3.0, False,
                   ["errors detected", "reconstruction degrading", "sector signal corrupted", "sensor loss in sector"],
                   ["this is fine", "everything is under control", "nothing to see here"]),
    "loss_gate": (1.0, True, ["gate breached"], []),
    "loss_city": (1.0, True,
                  ["corruption has reached the city", "third dimension lost", "the city has no depth", "z axis lost"],
                  []),
    "victory": (1.0, False,
                ["line held", "rift sealed", "sector clear", "area secured", "hostiles cleared", "well fought", "mission accomplished"],
                [("GG EZ", "gee gee easy"), "that's a wrap", "flawless victory"]),
    "codex": (1.0 / 12.0, False,
              ["searching database", "record retrieved", "consulting archives", "help text loaded"],
              ["let me look that up", "reading the manual"]),
    "refuse": (1.0 / 8.0, False,
               ["negative", "unable to comply"],
               ["not enough minerals", "you must construct additional pylons"]),
    "skirmish_open": (1.0, False,
                      ["feed live", "combat feed online", "weapons hot", "telemetry online", "reconstruction handed over"],
                      ["reactor online, sensors online, weapons online, all systems nominal"]),
}


def shown(line):
    return line[0] if isinstance(line, tuple) else line


def spoken(line):
    return line[1] if isinstance(line, tuple) else line


def slug(text):
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_")


def render_line(text, scale=1.35):
    raw = P.render("jenny", text, scale)
    return V.level_for_phone(P.mid_tamed(raw), -14.0)


def main(argv):
    os.makedirs(X.OUT, exist_ok=True)
    path = os.path.join(X.OUT, "manifest.json")
    manifest = {}
    if os.path.exists(path):
        with open(path) as fh:
            manifest.update(json.load(fh))
    manifest["lines"] = []
    for hook, (chance, info, normal, personality) in HOOKS.items():
        for line in normal + personality:
            text = shown(line)
            F.seed(PREFIX + slug(text))
            x = render_line(spoken(line))
            name = PREFIX + slug(text)
            X.write(name, X.tail(x, 0.3))
            manifest["lines"].append({"name": name, "hook": hook, "text": text, "personality": line in personality, "seconds": round(len(x) / SR, 2)})
            print("  %-20s %-52s %5.2f s" % (hook, text, len(x) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

"""Jenny's lines: the console's voice as a system, proposed (Ryan, 7 October). She is infrequent
and surprising: many phrases on many hooks, each hook firing a line only sometimes, with space
between lines so she never rattles off several at once.

The system (for sound.gd when it lands):

  chance      each hook has a chance that a trigger says a line at all; information hooks (a
              machine lost, a component damaged or destroyed, the gate damaged, a loss) say one
              every time, since that is actual information.
  spacing     one line at a time, never overlapping, and a gap of SPACING seconds between
              lines; a line that waited longer than STALE seconds is dropped unsaid, except an
              information line, which waits its turn.
  variety     a hook draws from its pool without repeating until the pool is spent (a shuffle
              bag per pool).
  personality the rare layer: a line that fires has a PERSONALITY chance of being replaced by
              one from the hook's slang pool, where one exists, as if the machine were learning
              from its users or waking up; the fourth wall breaks here and nowhere else.
  register    CARE's: terse, military, utilitarian, soulless; the personality layer breaks it.

Rendered through the decided chain (Jenny, mid, slowed a third, plosives tamed) at -14 dB on
the phone.

    tools/spriter/.venv/bin/python tools/soundforge/voice_lines.py          # a taster into out/fx
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
                  ["target locked", "weapons free", "engaging", "firing solution set", "hostile acquired", "extreme prejudice authorised"],
                  ["rip and tear", "light them up", "going ballistic", "say hello"]),
    "kill_shot": (1.0 / 3.0, False,
                  ["eliminating", "neutralising hostile", "terminal solution", "removing target", "hostile will not survive"],
                  ["mopping up trash", "that one's done", "delete"]),
    "foe_down": (1.0 / 4.0, False,
                 ["hostile neutralised", "target destroyed", "contact down"],
                 ["get wrecked", "next"]),
    "foe_down_undead": (1.0 / 3.0, False,
                        ["remains returned to rest", "undead presence cleared", "bone count reduced"],
                        ["stay dead this time"]),
    "foe_down_demonic": (1.0 / 3.0, False,
                         ["demonic presence neutralised", "infernal unit purged", "hellspawn removed"],
                         ["back to hell", "knee deep"]),
    "foe_down_eldritch": (1.0 / 3.0, False,
                          ["unknowable horror purged", "geometry corrected", "anomaly resolved"],
                          ["that was not supposed to exist"]),
    "buff": (1.0 / 6.0, False,
             ["shield up", "buff applied", "armour online", "overcharge engaged", "unit is tanking"],
             ["pop the cooldowns", "big heals", "saving throw granted", "aggro redirected"]),
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
                    ["all units committed", "orders received, all units moving"],
                    ["let's go"]),
    "resolve_move": (1.0 / 3.0, False,
                     ["units moving", "moving to intercept", "hostiles advancing", "incoming", "contact predicted"],
                     ["here they come"]),
    "contact": (1.0 / 2.0, False,
                ["skirmish imminent", "contact", "hostiles in range"],
                ["showtime"]),
    "engage": (1.0 / 2.0, False,
               ["engaging", "feed acquired", "taking the feed live"],
               ["boss music", "oh, that's a big one"]),
    "boss": (1.0, False,
             ["primary hostile identified", "priority target, all units committed", "boss class contact"],
             ["oh, that's a big one", "boss music"]),
    "gate_attack": (1.0 / 2.0, False,
                    ["gate under attack", "gate taking fire", "gate under threat"],
                    ["they're in the walls"]),
    "gate_damaged": (1.0, True,
                     ["gate damaged", "gate integrity falling"],
                     []),
    "flattening": (1.0 / 3.0, False,
                   ["errors detected", "reconstruction degrading", "flattening spreading", "sensor loss in sector"],
                   ["this is fine"]),
    "loss_gate": (1.0, True, ["gate breached"], []),
    "loss_city": (1.0, True, ["the flattening has reached the city", "reconstruction lost"], []),
    "victory": (1.0 / 2.0, False,
                ["line held", "rift sealed", "sector clear"],
                ["GG", "that's a wrap"]),
    "codex": (1.0 / 12.0, False,
              ["searching database", "record retrieved", "consulting archives"],
              ["let me look that up"]),
    "refuse": (1.0 / 8.0, False,
               ["negative", "unable to comply"],
               ["not enough minerals", "you must construct additional pylons"]),
    "skirmish_open": (1.0 / 4.0, False,
                      ["feed live", "all systems nominal"],
                      ["reactor online, sensors online, weapons online, all systems nominal"]),
}

# the taster: two normal lines and one personality line per hook, where the pool has them
TASTER = {h: (v[2][:2] + v[3][:1]) for h, v in HOOKS.items()}


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
    for hook, texts in TASTER.items():
        chance, info, normal, personality = HOOKS[hook]
        for text in texts:
            F.seed(PREFIX + slug(text))
            x = render_line(text)
            name = PREFIX + slug(text)
            X.write(name, X.tail(x, 0.3))
            manifest["lines"].append({"name": name, "hook": hook, "text": text, "personality": text in personality, "seconds": round(len(x) / SR, 2)})
            print("  %-22s %-48s %5.2f s" % (hook, text, len(x) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

"""Jenny's lines: the console's voice as a system, proposed (Ryan, 7 October). She is infrequent
and surprising: many phrases on many hooks, each hook firing a line only sometimes, with space
between lines so she never rattles off several at once.

The system (for sound.gd when it lands):

  chance      each hook has a chance that a trigger says a line at all; information hooks (a
              machine lost, a component damaged or destroyed, heat past half, a loss) say one
              every time, since that is actual information; victory and the battle opening say
              one every time too (Ryan: common moments, obvious ones).
  pools       a hook's pool is its own plus any it merges (MERGE): a Horde foe falling draws
              from the generic foe-down pool and the Horde pool together, and every unit
              committed draws from both resolve pools, since all units moving is the norm.
  spacing     one line at a time, never overlapping, and a gap of SPACING seconds between
              lines; a line that waited longer than STALE seconds is dropped unsaid, except an
              information line, which waits its turn.
  variety     a hook draws from its merged pool without repeating until it is spent (a
              shuffle bag per hook).
  personality the rare layer: a line that fires has a PERSONALITY chance of being replaced by
              one from the merged personality pool, where there is one, as if the machine were
              learning from its users or waking up; the fourth wall breaks here and nowhere
              else. She is Irish, so her sentences may run Irish ("back te hell with ya").
  register    CARE's: terse, military, utilitarian, soulless; the personality layer breaks it.

Ryan's rule for the pools: a line he has heard stays unless he says cut or change; a candidate
he has not heard does not come in unless he says add; new lines in a round stay to be heard;
the information hooks keep theirs. The buff hook stays generic until the vocabulary is locked.

A line is a string, or a (shown, spoken) pair where the synthesiser needs another spelling to
say it right, or a (shown, spoken, pace) triple where one line wants its own pace.

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
PACE = 1.35          # the decided pace, the model slowed a third

# hook: (chance a trigger says a line, information?, normal pool, personality pool)
HOOKS = {
    "die_spent": (1.0 / 6.0, False,
                  ["target locked", "weapons free", "extreme prejudice authorised", "discharging", "ordnance engaged"],
                  ["light them up", "going ballistic"]),
    "foe_down": (1.0 / 4.0, False,
                 ["eliminating", "neutralising hostile", "target destroyed", "lethal force applied", "bogey down", "threat eliminated"],
                 ["mopping up trash", "get wrecked", "glitch removed"]),
    "foe_down_undead": (1.0 / 3.0, False,
                        ["undead anomaly cleared", "necrotic signature lost", "animation ceased"],
                        ["re-interred", "stay dead this time"]),
    "foe_down_demonic": (1.0 / 3.0, False,
                         ["demonic presence eliminated", "infernal unit purged", "hellfire contained"],
                         ["back te hell with ya", "not today, satan", "power overwhelming"]),
    "foe_down_eldritch": (1.0 / 3.0, False,
                          ["unknowable horror purged", "sanity restored", "anxiety levels reduced"],
                          ["that was not supposed to exist", "thank goodness"]),
    "buff": (1.0 / 6.0, False,
             ["shield up", "buff applied", "unit boosted", "countermeasures engaged"],
             ["saving throw granted", "rage mode activated"]),
    "heat_vented": (1.0 / 6.0, False,
                    ["venting", "heat sinks engaged", "cooling", "thermal load falling"],
                    ["whew", "that's much better"]),
    "heat_high": (1.0, True,
                  ["thermal load rising", "heat warning", "temperature climbing"],
                  ["hot hot hot", "toasty", "smoking"]),
    "machine_lost": (1.0, True,
                     ["machine lost", "unit destroyed"],
                     []),
    "component_damaged": (1.0, True,
                          ["component damaged", "hardpoint hit"],
                          []),
    "component_destroyed": (1.0, True,
                            ["component destroyed", "hardpoint lost"],
                            []),
    "resolve_all": (1.0 / 2.0, False,
                    ["all units committed", "full line advancing", "squad deployed"],
                    ["get 'em boys", "transform and roll out", ("roll out", "rrrroll out"), "let none survive", "your time has come"]),
    "resolve_move": (1.0 / 3.0, False,
                     ["orders received", "moving to intercept", "in transit", "moving out", "proceeding", "coordinates received", "executing strategy"],
                     ["stay on target", "sounds fun", "evil draws close", "go go go"]),
    "contact": (1.0 / 2.0, False,
                ["combat imminent", "contact", "hostiles in range", "enemy in range", "closing to contact"],
                ["showtime", "here we go"]),
    "engage": (1.0 / 2.0, False,
               ["engaging", "feed acquired", "weapons hot", "live feed", "the fight is on"],
               [("rip and tear", "rip and tare"), "battle music initiated", "so it begins", "let's dance"]),
    "boss": (1.0, False,
             ["primary hostile identified", "priority target, engaging"],
             ["oh, that's a big one", "that's a lot of hostile", "big lad", "big fella", "that's a lot of teeth", "oh no. no no no"]),
    "gate": (1.0 / 2.0, False,
             ["gate under attack", "gate taking damage", "gate integrity falling"],
             ["they're in the walls", "they're breaking through"]),
    "flattening": (1.0 / 3.0, False,
                   ["errors increasing", "reconstruction degrading", "sector signal corrupted"],
                   ["this is fine", "everything is under control", "known issue", "that's a lot of bugs"]),
    "loss_gate": (1.0, True, ["gate breached"], ["now you've done it"]),
    "loss_city": (1.0, True,
                  ["corruption has reached the city", "the city is lost"],
                  ["z axis lost"]),
    "victory": (1.0, False,
                ["line held", "rift sealed", "area secured", "hostiles cleared", "well fought, commander", "mission accomplished"],
                [("GG EZ", "gee gee easy"), ("flawless victory", "flawless victory", 1.55), "well, that was fun"]),
    "codex": (1.0 / 12.0, False,
              ["searching database", "record retrieved", "consulting archives", "help text loaded"],
              ["let me look that up", "reading the manual"]),
    "refuse": (1.0 / 8.0, False,
               ["negative", "unable to comply"],
               ["you must construct additional pylons"]),
    "battle_open": (1.0, False,
                    ["feed live", "combat feed online", "telemetry online", "deployment complete", "all units on the field", "sector loaded"],
                    ["reactor online, sensors online, weapons online, all systems nominal"]),
}

# a hook draws from its own pool and these others' together
MERGE = {
    "foe_down_undead": ["foe_down"],
    "foe_down_demonic": ["foe_down"],
    "foe_down_eldritch": ["foe_down"],
    "resolve_all": ["resolve_move"],
}


def shown(line):
    return line[0] if isinstance(line, tuple) else line


def spoken(line):
    return line[1] if isinstance(line, tuple) else line


def pace(line):
    return line[2] if isinstance(line, tuple) and len(line) > 2 else PACE


def slug(text):
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_")


def render_line(text, scale=PACE):
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
            x = render_line(spoken(line), pace(line))
            name = PREFIX + slug(text)
            X.write(name, X.tail(x, 0.3))
            manifest["lines"].append({"name": name, "hook": hook, "text": text, "personality": line in personality, "seconds": round(len(x) / SR, 2)})
            print("  %-20s %-52s %5.2f s" % (hook, text, len(x) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

"""Jenny's lines: the console's voice as a system, proposed (Ryan, 7 October). She is infrequent
and surprising: many phrases on many hooks, each hook firing a line only sometimes, with space
between lines so she never rattles off several at once.

The system (for sound.gd when it lands):

  chance      each hook has a chance that a trigger says a line at all; information hooks (a
              machine lost, a component damaged or destroyed, heat past three quarters, a loss) say one
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
say it right, or a (shown, spoken, pace) triple where one line wants its own pace, or a
(shown, spoken, pace, draw) quadruple pinning one of Piper's draws of it.

Rendered through the decided chain (Jenny, mid, slowed a third, plosives tamed) at -14 dB on
the phone. Every line in every pool is rendered, so each word can be judged.

    tools/spriter/.venv/bin/python tools/soundforge/voice_lines.py          # into out/fx
"""
import json
import math
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
                  ["target locked", "weapons free", "extreme prejudice authorised", "discharging", "ordnance engaged", "suppressing fire"],
                  ["light them up", "going ballistic", "rampage"]),
    "foe_down": (1.0 / 4.0, False,
                 ["eliminating", "neutralising hostile", "target destroyed", "lethal force applied", "bogey down", "threat eliminated"],
                 ["mopping up trash", "get wrecked", "bug squashed", "dodge this", "fatality"]),
    "foe_down_undead": (1.0 / 3.0, False,
                        ["undead anomaly cleared", "necrotic signature lost", "animation ceased"],
                        ["re-interred", "stay dead this time"]),
    "foe_down_demonic": (1.0 / 3.0, False,
                         ["demonic presence eliminated", "infernal unit purged", "horde unit banished"],
                         ["back to hell with you", "not today, satan"]),
    "foe_down_eldritch": (1.0 / 3.0, False,
                          ["unknowable horror purged", "sanity restored", "anxiety levels reduced"],
                          ["that was not supposed to exist", "thank goodness"]),
    "buff": (1.0 / 6.0, False,
             ["shield up", "buff applied", "unit boosted", "countermeasures engaged"],
             ["saving throw granted", "rage mode activated", "power overwhelming"]),
    "heat_vented": (1.0 / 6.0, False,
                    ["venting", "heat sinks engaged", "cooling", "thermal load falling"],
                    ["whew", "that's much better"]),
    "heat_high": (1.0, True,
                  ["thermal load approaching limit", "heat warning", "danger: internal temperature elevated"],
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
                    ["all units committed", "full line advancing", "full squad deployed"],
                    [("get 'em boys", "get 'em, boys", 1.2), "transform and roll out", "let none survive", "your time has come"]),
    "resolve_move": (1.0 / 3.0, False,
                     ["orders received", "moving to intercept", "in transit", "moving out", "proceeding", "coordinates received", "executing strategy"],
                     ["stay on target", "sounds fun", "evil draws close", "go go go"]),
    "contact": (1.0 / 2.0, False,
                ["combat imminent", "contact", "hostiles in range", "enemy in range", "closing to contact"],
                ["showtime", "here we go again"]),
    "engage": (1.0 / 2.0, False,
               ["engaging", "skirmish feed acquired", "weapons hot", "connecting to live feed", "transferring to tactical display", "initiating combat protocol"],
               [("rip and tear", "rip and tare"), "battle music initiated", "let's dance", "the fight is on"]),
    "boss": (1.0, False,
             ["primary target identified", "priority threat detected. engaging", "alert: approaching dangerous hostile", "initiating sector purge"],
             ["oh, that's a big one", "big lad", "big fella on route", "that's a lot of teeth", "nope nope nope"]),
    "gate": (1.0 / 2.0, False,
             ["gate under attack", "gate taking damage", "gate integrity falling"],
             ["they're in the walls", "they're breaking through"]),
    "flattening": (1.0 / 3.0, False,
                   ["errors increasing", "reconstruction degrading", "sector signal corrupted"],
                   ["this is fine", "I'm glitching out here"]),
    "loss_gate": (1.0, True, ["gate breached. the city is lost"], ["now you've done it"]),
    "loss_city": (1.0, True,
                  [("corruption has reached the city. estimated casualties: 100%", "corruption has reached the city. estimated casualties: one hundred percent")],
                  ["z axis lost"]),
    "victory": (1.0, False,
                ["hostiles cleared. the line holds", ("area secured. well fought, commander", "area secured. well fot commander"), "mission accomplished. the rift is sealed"],   # rewritten as sentence pairs (Ryan, 7 October: the combined lines read samey and stuck together)
                [("GG EZ", "gee gee easy"), ("flawless victory", "flawless victory", 1.55), "well, that was fun", ("we got paid, commander. first round's on me", "we got paid commander. first round's on me"),
                 "I love it when a plan comes together", ("this was a triumph. I'm making a note here: huge success", "this was a triumph. I'm making a note here: huge success", 1.45), "are you not entertained", "we came, we saw, we kicked its ass", "hell, it's about time", "the only good bug is a dead bug"]),   # homages (7 October): the A-Team kept; Portal, Gladiator, Ghostbusters, Tychus and Starship Troopers proposed in the second round; a vocative comma is dropped in the spoken form
    "codex": (1.0 / 12.0, False,
              ["searching database", "record retrieved", "consulting archives", "help text loaded"],
              ["let me look that up", "reading the manual"]),
    "refuse": (1.0 / 8.0, False,
               ["negative", "unable to comply"],
               ["you must construct additional pylons"]),
    "battle_open": (1.0, False,
                    ["battlefield feed online. all units reporting in", ("deployment complete. awaiting your orders, commander", "deployment complete. awaiting your orders commander"), "sector loaded. hostiles inbound"],
                    [("reactor online, sensors online, weapons online, all systems nominal", "reactor on-line, sensors on-line, weapons on-line, all systems nominal"), "once more, into the breach", "now for wrath. now for ruin. and the red dawn"]),
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


def pinned(line):
    return line[3] if isinstance(line, tuple) and len(line) > 3 else None


def slug(text):
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_")


# A line opening on one of these letters has a front Jenny may clip; one opening on a vowel,
# a nasal, a liquid or an h has nothing in the band the lift works on, and is left alone.
# A fricative opening (s, f, v, z, sh, a voiceless th) needs length as well as level: Ryan's
# calibration (7 October) put "sector loaded" (61 ms, 15 dB under its vowel) and "saving
# throw" (130 ms, 17 under) at perfect, "stay on target" (88 ms, 16 under) and "smoking"
# (50 ms, 19 under) at slightly clipped, "so it begins" (32 ms, 24 under) at barely an s.
ONSETS = "sftkcqpgdbjzv"
SOFT_TH = {"the", "that", "that's", "this", "these", "those", "they", "they're", "them", "their", "there", "there's", "then", "than", "though"}   # a voiced th is short by nature
DRAWS = 6             # draws tried for a weak front
WEAK = -30.0          # a stop this far under its vowel (dB) gets the other draws
FRIC_LEVEL = -16.0    # a fricative wants at least this
FRIC_SPAN = 0.05      # and at least this long (s)
FRIC_OUT = -18.0      # where an opening fricative is set on the finished line, dB under its vowel (his perfect lines were heard at 22 under, his clipped ones from 22 to 26)


def onset_kind(text):
    t = text.lower()
    word = re.split(r"[^a-z']", t, maxsplit=1)[0]
    if t[0] in "sfvz" or t.startswith("sh") or (t.startswith("th") and word not in SOFT_TH):
        return "fricative"
    return "stop" if t[0] in ONSETS else "open"


def front_score(raw):
    """Level plus length: a doubling of the span counts six decibels."""
    lo, hi, a, b, vpk = P.front_of(raw)
    span = max(b - a, F.n_of(0.005)) / F.SR
    return P.front_level(raw) + 20.0 * math.log10(span / FRIC_SPAN), span


def front_weak(kind, raw):
    lvl = P.front_level(raw)
    if kind == "fricative":
        return lvl < FRIC_LEVEL or front_score(raw)[1] < FRIC_SPAN
    return kind == "stop" and lvl < WEAK


def pick_draw(text, scale, pin=None):
    """Piper samples, and the first phoneme of an utterance is where the draws differ most
    (measured 7 October: "so it begins" opens at 11 to 24 dB under its vowel across six
    draws, "target destroyed" at 14 to 28). A pinned draw is taken as is. Otherwise the first
    draw stays, as heard, unless its front is weak; then the best front of six, by level for
    a stop and by level and length for a fricative. Returns the audio, the draw and the levels."""
    if pin is not None:
        raw = P.render("jenny", text, scale, pin)
        return raw, pin, P.front_level(raw), P.front_level(raw)
    kind = onset_kind(text)
    raw = P.render("jenny", text, scale)
    lvl = P.front_level(raw)
    if not front_weak(kind, raw):
        return raw, 0, lvl, lvl
    key = front_score if kind == "fricative" else (lambda r: (P.front_level(r), 0.0))
    best = (key(raw)[0], 0, raw)
    for d in range(1, DRAWS):
        y = P.render("jenny", text, scale, d)
        k = key(y)[0]
        if k > best[0]:
            best = (k, d, y)
    return best[2], best[1], lvl, P.front_level(best[2])


def render_line(text, scale=PACE, pin=None):
    raw, draw, l0, l1 = pick_draw(text, scale, pin)
    raw = P.shorten_pauses(raw, text)
    kind = onset_kind(text)
    if kind != "open":
        raw = P.lift_front(raw)
    y = P.mid_tamed(raw, protect_front=(kind == "fricative"))
    if kind == "fricative":
        y = P.set_front(y, FRIC_OUT)
    return V.level_for_phone(y, -14.0), {"draw": draw, "front": round(l0, 1), "front_drawn": round(l1, 1), "front_lifted": round(P.front_level(raw), 1), "front_out": round(P.front_level(y), 1)}


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
            x, front = render_line(spoken(line), pace(line), pinned(line))
            name = PREFIX + slug(text)
            X.write(name, X.tail(x, 0.3))
            manifest["lines"].append(dict({"name": name, "hook": hook, "text": text, "personality": line in personality, "seconds": round(len(x) / SR, 2)}, **front))
            print("  %-20s %-52s %5.2f s  draw %d  front %6.1f -> %6.1f -> %6.1f -> out %6.1f" % (hook, text, len(x) / SR, front["draw"], front["front"], front["front_drawn"], front["front_lifted"], front["front_out"]))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

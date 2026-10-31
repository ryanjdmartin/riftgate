"""Hold The Line's eighth round as a pair (Ryan, 30 October, on the seventh round's page): the map minimal.

  the lifts      "Hold the Line map lifts are just too busy. A lot of the first lift's issue is the
                 bells are too busy, and for both the 'as it was' is kind of the best ones. Maybe
                 with the tine piano added. But in general the map tracks need to be minimalist."
                 Both lifts as they were, the first lift's bell down to one a bar where it played
                 the battle chime's eighths with its echoes; the tine piano on the riff a row in
                 each lift's set.
  K              "map K - go with a single harp and single piano and let me hear it in context":
                 the harp on the walk and the piano's solo and nothing else, heard from the
                 climax's last set through the breath, K, V and Q's fill beside K as it was.

Kept from the earlier rounds: the battle half as the seventh round has it (the loop without J, V
and Q kept, Q's fill landing on the wrap at bar nine with a crash; the first lift on the crunch
synth and the synth lead and the second on the crunch synth and the lead guitar over the backing
guitar 6 dB down, a crash every four bars; M as it ships with the crunch synth; K's first fourteen
bars at its slower tempo on the drums in between with the lead guitar added to the walk and its
long crash choked to a second and a half); his map picks (X's held walk on the violins, U's lead
on the clean guitar, the climax's drone moved from S to R, W on the low note with the roll). The
seventh round's map voices for the battle's new parts (the ticking under the lifts, their riff on
the clean guitar and the harp, K's walk on the clean guitar) are gone with his call.

The full pair on the switch takes every pick. The sets are excerpts of the map half for A/B, every
row the same bars from the same seed through one master at one gain.

    tools/spriter/.venv/bin/python tools/soundforge/hold_sketches.py          # every set and the pair, then hold8.json beside the pairs (about five minutes on four cores)
    tools/spriter/.venv/bin/python tools/soundforge/hold_sketches.py mc mk    # the named sets only (mc ml mk, and full for the pair)
"""
import json
import os
import sys
from concurrent.futures import ProcessPoolExecutor

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import pair_sketches as P  # noqa: E402

NAME = "music_hold_the_line"
SHIPPED_FORM = F.MUSIC[NAME]["form"]
METER = dict(F.MUSIC[NAME]["meter"])            # the seven in 7/8, K and V at the solo's slower tempo (Ryan, 30 October: "keep the tempo drop")
FORM_K16 = SHIPPED_FORM.replace(" JJ", "")       # the loop without J: Q's fill into the wrap
FORM_K14 = FORM_K16.replace("K" * 16, "K" * 14)  # K's first fourteen bars
BATTLE_LEVEL = F.LEVELS[NAME]
MAP_LEVEL = P.MAP_LEVEL


# ---------------------------------------------------------------- a call, read and edited

def call_on(form, meter):
    """The battle recipe's groove call on another form."""
    saved = dict(F.MUSIC[NAME])
    F.MUSIC[NAME]["form"], F.MUSIC[NAME]["meter"] = form, meter
    try:
        return P.recipe_call(F.music_hold_the_line)
    finally:
        F.MUSIC[NAME].clear()
        F.MUSIC[NAME].update(saved)


def copied(call):
    """A call whose voices, drums, chords and pads can be edited without touching the recipe's."""
    out = dict(call)
    out["voices"] = [dict(v, pat=dict(v["pat"])) for v in call["voices"]]
    out["drums"] = {k: dict(d) for k, d in call["drums"].items()}
    out["chords"] = dict(call["chords"])
    out["pad"] = [dict(p) for p in call.get("pad") or []]
    out["drum_gain"] = dict(call.get("drum_gain") or {})
    return out


def run_steps(form, part, meter=None, default="."):
    """F._steps as it reads a form with a seven in it: a pattern that fits its bar whole is read
    from its run's start, the rest by the loop's own step. The track has its seven, an excerpt
    in four-four alone would be read by the loop's step and start a lift's riff mid-phrase, so
    every excerpt is read this way and plays each section as the track does."""
    steps, starts, _ = F._bars(form, meter)
    out, run_start = [], 0
    for bar, sec in enumerate(form):
        if bar > 0 and form[bar - 1] != sec:
            run_start = bar
        pat = part.get(sec, part.get("*", default * steps[bar]))
        base = starts[bar] - starts[run_start] if len(pat) % steps[bar] == 0 else starts[bar]
        out.append("".join(pat[(base + i) % len(pat)] for i in range(steps[bar])))
    return "".join(out)


def matches(v, inst, section, mode, match):
    return v["inst"] == inst and section in v["pat"] and v.get("mode", "riff") == mode and all(v.get(k, 0) == w for k, w in match.items())


# An emptied voice stays in the list: the forge seeds each voice's slop by its place in the list,
# so dropping one would move every later voice's timing and the rows of a set would differ where
# nothing was changed.

def strip(call, inst, section, mode="riff", **match):
    """Every matching voice's pattern for the section dropped."""
    for v in call["voices"]:
        if matches(v, inst, section, mode, match):
            del v["pat"][section]


def add(call, **voice):
    call["voices"].append(voice)


def drums(call, section, **parts):
    """A section's drums: the named parts set (an empty string clears one)."""
    for name, pat in parts.items():
        call["drums"].setdefault(name, {})
        if pat:
            call["drums"][name][section] = pat
        else:
            call["drums"][name].pop(section, None)


def roots_of(call, section, bars):
    chords = call["chords"][section]
    return [P.spell(chords[b % len(chords)][0]) for b in range(bars)]


# ---------------------------------------------------------------- the lifts and M (the battle half)

LIFT_RIFF = "8-.c.8-a.8-.5-.38-.c.8-a.3-.5-.7"   # C E C D C A G C, E C D G A B: both lifts' riff
LEAD_GUITAR = {"mute": False, "cutoff": 2400.0, "clean": True}   # the climax's lead guitar voice
RIFF_VOICES = {
    "sub": {"inst": "sub_bass", "mode": "riff", "hold": 1.0},                                          # the first lift's own
    "bass": {"inst": "bass_real", "mode": "riff", "hold": 1.1, "params": {"drive": 3.5}},              # the driven bass
    "crunch": {"inst": "bass", "mode": "riff", "hold": 1.0, "params": {"drive": 3.5, "cutoff": 800.0}},   # the second lift's own
    "lead": {"inst": "guitar_real", "mode": "riff", "hold": 0.9, "params": LEAD_GUITAR},               # the lead guitar voice
    "synth": {"inst": "lead", "mode": "riff", "hold": 0.9},                                            # the track's synth lead
}
CRUNCH_SYNTH = (("crunch", 0.4), ("synth", 0.42))  # the first lift (Ryan, sixth round: "actually perfect"): 0.42 meets the lead guitar's 0.4 on the speaker
CRUNCH_LEAD = (("crunch", 0.4), ("lead", 0.4))     # the second (seventh: "keep Crunch synth and lead guitar for second lift")
BACKING = 0.31   # the backing guitar 6 dB under the fourth round's 0.62 (Ryan: "lower the backing guitar volume a bunch")


def kick_chug(call, section):
    """A backing guitar chugging each bar's root wherever the kick hits: the lifts' syncopation, locked."""
    kick = call["drums"]["kick"][section]
    return "".join(kick.replace("x", r) for r in roots_of(call, section, 4))


def lift_band(call, s, backing=BACKING):
    """Ryan's pick of the second round (the first lift's second row): a backing guitar chugging
    each bar's root wherever the kick hits, a crash every four bars."""
    add(call, inst="guitar_real", mode="riff", gain=backing, octave=-1, pat={s: kick_chug(call, s)})
    drums(call, s, crash="x" + "." * 63)


def riff_on(call, s, *pair, pat=LIFT_RIFF):
    """A section's line on two voices in unison, each (voice, gain), in place of its own voices."""
    strip(call, "sub_bass", s)
    strip(call, "bass", s)
    for name, gain in pair:
        add(call, **dict(RIFF_VOICES[name], gain=gain, pat={s: pat}))


def lift(s, *pair, backing=BACKING):
    """A lift's row: the chug and the crashes, and the riff on `pair` when one is given."""
    def edit(call):
        lift_band(call, s, backing)
        if pair:
            riff_on(call, s, *pair)
    return edit


def m_crunch(call):
    """M, the bar down into the seven, as it ships (the chug and the driven bass) with the crunch
    synth on the chug's line an octave up, as the fourth round's M had it (Ryan, 30 October)."""
    add(call, **dict(RIFF_VOICES["crunch"], gain=0.4, pat={"M": P.part(call, "guitar_real", "M", octave=-1)}))


# ---------------------------------------------------------------- K (the battle half)

def wrap_crash(call):
    """Q's fill lands on the wrap at bar nine, the riff's power chords: a crash there, as at J's
    door before (the track's top stays bare)."""
    drums(call, "A", crash="." * 128 + "x" + "." * 127)


def k_between(call):
    """K's drums between how they were and the climax's: its own kick pushing on the and of two
    and into the next bar, a ghost either side of its snare on three, eighths on the hat with the
    open hat on the and of four, a china on three every second bar, the drums a little up; its
    long crashes, splashes and toms as they were. What a phone plays of it is the cymbals and the
    snare: inside K it sits 16 dB under the mix there, where the climax's drums sat 12."""
    drums(call, "K", kick="x.....x.x.......x.....x.x...x.x.", snare="......o.x......o", hat="x.x.x.x.x.x.x...",
          open="..............x.", china="........x......." + "." * 16)
    call["drum_gain"]["K"] = 1.08


def k_lead(call, alone=False):
    """The lead guitar voice on K's walk, in unison with the crunch synth or in its place."""
    walk = P.part(call, "bass", "K")
    if alone:
        strip(call, "bass", "K")
    add(call, **dict(RIFF_VOICES["lead"], gain=0.45 if alone else 0.4, hold=1.0, pat={"K": walk}))


def shortened(x, t20):
    """A cymbal choked sooner: an extra exponential fall over the whole hit, set so it falls 20 dB
    by `t20` seconds, then cut where it is 50 dB down."""
    env = np.sqrt(np.convolve(x ** 2, np.ones(441) / 441.0, mode="same"))
    t = np.arange(len(x)) / F.SR
    top = env.max()

    def fall(rate):   # dB a second of the extra fall
        return env * 10.0 ** (-rate * t / 20.0)
    lo, hi = 0.0, 400.0
    for _ in range(40):
        rate = (lo + hi) / 2.0
        if np.where(fall(rate) > top * 0.1)[0].max() / F.SR > t20:
            lo = rate
        else:
            hi = rate
    y = x * 10.0 ** (-hi * t / 20.0)
    end = int(np.where(fall(hi) > top * 10.0 ** (-50.0 / 20.0))[0].max())
    y = y[:end + 1]
    n = min(len(y), int(0.02 * F.SR))
    y[-n:] *= np.linspace(1.0, 0.0, n)
    return y


K_CRASH = 1.5   # seconds to fall 20 dB (Ryan: "lets try 1.5s?", then "1.5s crash in K"; its long crash took 2.4)


def k_crashes(t20=K_CRASH):
    """K's long crash, every second bar, choked (Ryan: "Shorten the crashes, they're too much now
    that the drums are doing more"); K is the only section that plays it."""
    def edit(call):
        sound, gain = call["kit"]["crash_long"][:2]
        call["kit"]["crash_long"] = ([shortened(s, t20) for s in sound], gain)
    return edit


def k_step(step):
    """K's fourteen bars a step at a time: 0 as it was, 1 the drums in between, 2 the lead guitar
    added to the walk, 3 the lead guitar alone on the walk."""
    def edit(call):
        if step >= 1:
            k_between(call)
        if step >= 2:
            k_lead(call, alone=step == 3)
    return edit


# ---------------------------------------------------------------- the map half
# A map edit takes the map's arguments and the battle call they were built from.

VIOLINS_X = {"inst": "violin_real", "mode": "riff", "gain": 0.175, "octave": 2, "legato": True}   # at the cellos' level on the speaker
CLEAN_GUITAR_U = {"inst": "guitar_real", "mode": "riff", "gain": 0.26, "octave": 1, "hold": 1.5,
                  "params": {"mute": False, "clean": True}}   # at the harp's level on the speaker
W_CELLO, W_ROLL = 0.2, 0.845   # Ryan, 30 October: the cellos at -6 dB, the roll at +9 dB, of the second round's 0.4 and 0.3


def tuned_timpani(semis):
    """The forge's timpani (62 Hz, about B1) retuned to a note between E2 and D sharp 3, a real
    timpani's range and one a phone's speaker can sound, from a stream of its own, so adding it
    leaves every other random draw of the render (the pads' sweeps) where it was."""
    saved, F.RNG = F.RNG, np.random.default_rng(100 + semis)
    try:
        x = F.timpani_real()
    finally:
        F.RNG = saved
    ratio = F.E2 * 2.0 ** ((semis % 12) / 12.0) / 62.0
    return np.interp(np.arange(0.0, len(x) - 1, ratio), np.arange(len(x)), x)


def timpani(kw, section, notes, gain, pattern="x..............."):
    """A timpani under a section, tuned as it goes: `notes` is each `pattern`'s note in turn
    (semitones above E), one drum a note and section."""
    for semis in sorted(set(notes)):
        name = "timp_%s%d" % (section, semis)
        kw["kit"][name] = ([tuned_timpani(semis)], gain)
        kw["drums"][name] = {section: "".join(pattern if n == semis else "." * len(pattern) for n in notes)}


def map_drone(kw, call=None):
    """The drone 4 dB down (Ryan: it needs to come down), out of the climax's first set and
    arriving with its second (his idea for R, picked in the second round)."""
    for p in kw["pad"]:
        if p["inst"] == "sweep" and p.get("chord"):
            p.update(gain=0.25, sections="ANRZ")
    return kw


def map_voice(kw, inst, section, new):
    """The map's voice for a section swapped: the section moved off its voice onto `new`."""
    for v in kw["voices"]:
        if v["inst"] == inst and section in v["pat"]:
            kw["voices"].append(dict(new, pat={section: v["pat"].pop(section)}))
            return kw
    raise KeyError("no %s plays %s" % (inst, section))


def w_low(kw, call):
    """W dropped to a low note: the horn's held B goes, a cello holds B low through both bars with a
    contrabass an octave under it, under the piano's last note and the sub, and a timpani rolls
    on B through the second bar into the climax."""
    strip(kw, "horn_real", "W")
    kw["voices"].append({"inst": "cello_real", "mode": "riff", "gain": W_CELLO, "octave": 0, "legato": True, "pat": {"W": "7" + "-" * 31}})
    kw["voices"].append({"inst": "contrabass_real", "mode": "riff", "gain": 0.34, "octave": -1, "legato": True, "pat": {"W": "7" + "-" * 31}})
    timpani(kw, "W", [7], W_ROLL, pattern="." * 16 + "x...x...x.x.xxxx")
    return kw


def map_picks(kw, call):
    """The map half with every pick so far: the drone down and moved, X on the violins, U on the
    clean guitar, W low with the roll; K without the cellos (its walk on the ticking guitar, the
    sub on its roots, a timpani on each bar's one tuned to its root, very soft); the map's lifts,
    V and Q as they were."""
    map_drone(kw)
    map_voice(kw, "cello_real", "X", VIOLINS_X)
    map_voice(kw, "harp", "U", CLEAN_GUITAR_U)
    w_low(kw, call)
    strip(kw, "cello_real", "K")
    kw["voices"].append(dict(P.TICKING, gain=0.22, pat={"K": P.part(call, "bass", "K")}))
    kw["voices"].append({"inst": "sub_bass", "mode": "riff", "gain": 0.34, "legato": True, "pat": {"K": P.roots(call, "K")}})
    chords = call["chords"]["K"]
    timpani(kw, "K", [chords[b % len(chords)][0] % 12 for b in range(call["form"].count("K"))], 0.28)
    return kw


# ---------------------------------------------------------------- the map half, minimal

# The map halves are minimal (Ryan, 30 October: "in general the map tracks need to be minimalist").
# The seventh round's voices for the battle's new parts went with that call; what stays is a lift's
# riff on the tine piano (the map's voice for the riff in A and N) to try, and K on a single harp
# and a single piano. A voice's gain sets it at the phone level of U's clean guitar in U.
MAP_HARP = {"inst": "harp", "mode": "riff", "octave": 1, "hold": 1.5}
MAP_TINE = {"inst": "epiano", "mode": "riff", "octave": 2, "hold": 1.4}
MAP_LEADS = {("C", "tine"): 0.18, ("L", "tine"): 0.18, ("K", "harp"): 0.49}   # (section, voice): gain
MAP_VOICES = {"harp": MAP_HARP, "tine": MAP_TINE}
CALM_BELL = "0..............."   # the first lift's bell, one a bar (Ryan: "the bells are too busy")


def map_lead(s, name):
    """A map voice on a section's line: a lift's riff, or K's walk."""
    def edit(kw, call):
        kw["voices"].append(dict(MAP_VOICES[name], gain=MAP_LEADS[s, name], pat={s: LIFT_RIFF if s in "CL" else P.part(call, "bass", s)}))
        return kw
    return edit


def map_calm_bell(kw, call):
    """The first lift's bell, which played the battle chime's eighths with its echoes, once a bar."""
    for v in kw["voices"]:
        if v["inst"] == "bell" and "C" in v["pat"]:
            v["pat"]["C"] = CALM_BELL
    return kw


def map_k_single(kw, call):
    """K on a single harp and a single piano: the harp on the walk, the piano's solo, nothing else
    (the walk's ticking guitar, the sub, the timpani, the piano's held chords and the pads go)."""
    for v in kw["voices"]:
        if "K" in v["pat"] and not (v["inst"] == "epiano" and v.get("mode", "riff") == "riff"):
            del v["pat"]["K"]
    for name in [n for n in kw["drums"] if n.startswith("timp_K")]:
        del kw["drums"][name]
    for p in kw["pad"]:
        p["sections"] = p["sections"].replace("K", "")
    return map_lead("K", "harp")(kw, call)


def map_edits(*edits):
    def edit(kw, call):
        for e in edits:
            kw = e(kw, call)
        return kw
    return edit


# The map half of the eighth round: every pick so far, the first lift's bell calmer, K on a harp and a piano.
map_eight = map_edits(map_picks, map_calm_bell, map_k_single)


# ---------------------------------------------------------------- the renders

def unmastered(kw):
    """A call up to its master and no further, with the master's settings: the master brings a mix
    under its knee by the mix's own peak, so a row whose peak a part raises would come out quieter
    everywhere; a set's rows are mastered together instead (`master_together`)."""
    settings = (kw.get("headroom"), kw.get("master", 1.25))
    kw.update(headroom=None, master=1e-3)   # tanh at a thousandth of its drive: linear to a part in a million
    return F.groove(**kw), settings


def master_together(rows):
    """A set's unmastered rows through one master: one division by the loudest row's peak, then
    the master's saturation, so the rows differ only by what changed."""
    (headroom, drive), = {s for _x, s in rows}
    under = max(1.0, max(float(np.max(np.abs(x))) for x, _s in rows) / headroom) if headroom else 1.0
    return [F.sat(x / under, drive) for x, _s in rows]


def map_call(form, edit=None, meter=None):
    """The map half's call on a form: the battle's call as it ships (the map follows its notes; the
    battle's edits add voices the map re-voices in its own edit), the map's arrangement over it,
    then the map's edit."""
    call = copied(call_on(form, meter or METER))
    kw = dict(call)
    kw.update(P.map_hold_the_line(call))
    kw["drum_gain"] = {}   # the map's drums are its own, at their written gains
    return edit(kw, call) if edit else kw


def map_half(form, edit=None, meter=None):
    return F.groove(**map_call(form, edit, meter))


C_FORM = "NNNN B CCCCCCCC NNNN"
L_FORM = "NNNN LLLLLLLL M XX"
K_CONTEXT = "ZZZZ Y " + "K" * 14 + " V Q"


def round_seven(call):
    """The battle half with every pick: the wrap's crash, the first lift on the crunch synth and
    the synth lead and the second on the crunch synth and the lead guitar, over the quieter backing
    guitar, M as it ships with the crunch synth, K on the drums in between with the lead guitar
    added to the walk and its crash choked to a second and a half."""
    wrap_crash(call)
    lift("C", *CRUNCH_SYNTH)(call)
    lift("L", *CRUNCH_LEAD)(call)
    m_crunch(call)
    k_step(2)(call)
    k_crashes()(call)


SETS = [
    {"id": "mc", "half": "map", "title": "The map's first lift (C)", "form": C_FORM,
     "note": "From the riff's end through the turn, the lift and the riff again: the soft sub on the riff, the piano's chords on the beats, the choir and the bell.", "rows": [
        ("mc0", "As it was", "The bell on the battle chime's eighths with its echoes.", map_picks),
        ("mc1", "The bell calmer", "One bell a bar (the full pair's).", map_edits(map_picks, map_calm_bell)),
        ("mc2", "And the tine piano on the riff", "The bell calmer and the riff on the tine piano two octaves up.", map_edits(map_picks, map_calm_bell, map_lead("C", "tine"))),
    ]},
    {"id": "ml", "half": "map", "title": "The map's second lift (L) into M", "form": L_FORM,
     "note": "From the riff into the lift, M and the seven: the soft sub and the spiccato cellos on the riff, the piano's chords on the beats.", "rows": [
        ("ml0", "As it was", "The full pair's.", map_picks),
        ("ml1", "And the tine piano on the riff", "The riff on the tine piano two octaves up as well.", map_edits(map_picks, map_lead("L", "tine"))),
    ]},
    {"id": "mk", "half": "map", "title": "The map's K in context", "form": K_CONTEXT,
     "note": "Four bars of the climax, the breath, K's fourteen bars at its slower tempo, V and Q's fill.", "rows": [
        ("mk0", "As it was", "The walk on the ticking guitar, the sub on its roots, a soft timpani, the piano's solo over its held chords and the pads.", map_picks),
        ("mk1", "A single harp and a single piano", "The harp on the walk and the piano's solo, nothing else (the full pair's).", map_edits(map_picks, map_k_single)),
    ]},
]
PAIR = {"id": "hold_the_line_r8", "title": "Hold The Line, round eight",
        "k": "the keyboard solo's first fourteen bars at its slower tempo, the lead guitar with the crunch synth on the walk, K's drums with a pushing kick, eighths on the hat and a china, its crash choked to a second and a half"}


def level(x, db):
    return F.limit(F.write_level(x, NAME, db))


def render_row(job):
    """One row of a set, in a worker, from its set's seed; read as the track reads its sections."""
    si, ri = job
    F.seed("hold8_" + SETS[si]["id"])
    _rid, _title, _note, edit = SETS[si]["rows"][ri]
    with P.Patched(_steps=run_steps):
        return si, ri, unmastered(map_call(SETS[si]["form"], edit))


def full_path(half):
    return os.path.join(P.OUT, "hold8_full_%s.wav" % half)


def render_full(half):
    """One full half, in a worker, from the shipped half's seed, at its half's level."""
    if half == "battle":
        F.seed(NAME)
        call = copied(call_on(FORM_K14, METER))
        round_seven(call)
        x = level(F.groove(**call), BATTLE_LEVEL)
    else:
        F.seed(NAME + "_map")
        x = level(map_half(FORM_K14, map_eight), MAP_LEVEL)
    P.write(os.path.basename(full_path(half))[:-4], x, aac=False)
    return half


def bars_of(form, meter, bpm):
    form = form.replace(" ", "")
    steps, _, scales = F._bars(form, meter)
    return form, np.concatenate([[0.0], np.cumsum([s * k * 15.0 / bpm for s, k in zip(steps, scales)])])


def sections_of(form, meter, bpm, k_name=None):
    form, at = bars_of(form, meter, bpm)
    names = dict(F.MUSIC[NAME]["names"])
    if k_name:
        names["K"] = k_name
    out, b = [], 0
    while b < len(form):
        e = b
        while e < len(form) and form[e] == form[b]:
            e += 1
        out.append({"section": form[b], "bars": [b + 1, e], "at": round(float(at[b]), 2), "what": names.get(form[b], "")})
        b = e
    return out, float(at[-1]), at


def main(argv):
    wanted = argv or [s["id"] for s in SETS] + ["full"]
    os.makedirs(P.OUT, exist_ok=True)
    jobs = [(si, ri) for si, s in enumerate(SETS) if s["id"] in wanted for ri in range(len(s["rows"]))]
    with ProcessPoolExecutor(max_workers=4) as pool:
        full_runs = [pool.submit(render_full, h) for h in (("battle", "map") if "full" in wanted else ())]
        raw = {(si, ri): x for si, ri, x in pool.map(render_row, jobs)}
        for f in full_runs:
            f.result()
    manifest_path = os.path.join(P.OUT, "hold8.json")
    manifest = json.load(open(manifest_path)) if os.path.exists(manifest_path) else {"sets": [], "tracks": [], "seams": []}
    for si, s in enumerate(SETS):
        if s["id"] not in wanted:
            continue
        # One master and one gain for the set, the gain the one that brings its first row to its
        # half's level, so the rows differ only by what changed.
        mastered = master_together([raw[si, ri] for ri in range(len(s["rows"]))])
        gain = 10.0 ** (((BATTLE_LEVEL if s["half"] == "battle" else MAP_LEVEL) - F.mean_level(mastered[0])) / 20.0)
        rows = []
        for ri, (rid, title, note, _edit) in enumerate(s["rows"]):
            x = F.limit(mastered[ri] * gain)
            rows.append({"id": rid, "title": title, "note": note, "file": os.path.basename(P.write("hold8_" + rid, x)),
                         "seconds": round(len(x) / F.SR, 2), "phone_db": P.measure(rid, x)["phone_db"]})
        manifest["sets"] = [e for e in manifest["sets"] if e["id"] != s["id"]] + [{"id": s["id"], "half": s["half"], "title": s["title"], "note": s["note"], "rows": rows}]
        print("%-2s %s" % (s["id"], "  ".join("%s %.1f" % (r["id"], r["phone_db"]) for r in rows)))
    manifest["sets"].sort(key=lambda e: [s["id"] for s in SETS].index(e["id"]))
    manifest["seams"] = []
    if "full" in wanted:
        bpm = F.MUSIC[NAME]["bpm"]
        m, b = (P.read_wav(full_path(h)) for h in ("map", "battle"))
        if len(m) != len(b):
            raise ValueError("the halves are %d and %d samples" % (len(m), len(b)))
        P.write(PAIR["id"] + "_pair", [m, b], kbps=384)
        secs, total, at = sections_of(FORM_K14, METER, bpm, PAIR["k"])
        levels = [P.measure("map", m), P.measure("battle", b)]
        manifest["tracks"] = [{"id": PAIR["id"], "title": PAIR["title"], "new": "both", "bpm": bpm, "length": round(total, 3),
                               "loop_from_bar": 9, "bar_at": [round(float(t), 4) for t in at[:-1]], "sections": secs, "levels": levels}]
        print("%s  map %.1f (phone %.1f)  battle %.1f (phone %.1f)" % (PAIR["id"], levels[0]["mean_db"], levels[0]["phone_db"], levels[1]["mean_db"], levels[1]["phone_db"]))
    with open(manifest_path, "w") as f:
        json.dump(manifest, f, indent=1)
    print(os.path.relpath(manifest_path))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

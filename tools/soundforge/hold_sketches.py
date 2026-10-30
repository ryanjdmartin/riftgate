"""Hold The Line's fifth round as a pair (Ryan, 30 October, on the fourth round's page):

  the lifts      "crunch and synth for both lifts, and lower the backing guitar volume a bunch":
                 read as the fourth round's pick for both, the crunch synth and the lead guitar,
                 with the backing guitar 6 dB down (10 dB in a row beside it), and one row on the
                 crunch synth and the track's own synth lead in case that is what he meant.
  M              "I was wrong about M, it needs to go with how it ships, but add the crunch synth
                 to it": the chug and the driven bass as they ship, the crunch synth on the chug's
                 line an octave up as the fourth round had it.
  K              "in between drums and the add lead to the unison, yes. Shorten the crashes,
                 they're too much now that the drums are doing more": K's long crash, every second
                 bar, choked to fall 20 dB in about a second, as the track's other crashes do (half
                 a second in a row beside it).

Kept from the earlier rounds: only J goes, V and Q stay, Q's fill landing on the wrap at bar nine
with a crash; K at its slower tempo, its first fourteen bars; both lifts with the backing guitar
chugging each bar's root wherever the kick hits and a crash every four bars, their metal chime
and piano as they were; his map picks (X's held walk on the violins, U's lead on the clean
guitar, the climax's drone moved from S to R, W on the low note with the roll, K without the
cellos), the map half as the fourth round's.

The full pair on the switch takes every pick: the lifts on the crunch synth and the lead guitar
over the quieter backing guitar, M as it ships with the crunch synth, K on the drums in between
with the lead guitar added to the walk and its crashes choked. The sets are excerpts for A/B,
every row the same bars from the same seed at one gain.

    tools/spriter/.venv/bin/python tools/soundforge/hold_sketches.py          # every set and the pair, then hold5.json beside the pairs (about five minutes on four cores)
    tools/spriter/.venv/bin/python tools/soundforge/hold_sketches.py c m      # the named sets only (c m k, and full for the pair)
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
METER = dict(F.MUSIC[NAME]["meter"])            # the seven in 7/8, K and V at the solo's slower tempo
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
CRUNCH_LEAD = (("crunch", 0.4), ("lead", 0.4))     # Ryan's pick for both lifts (30 October)
CRUNCH_SYNTH = (("crunch", 0.4), ("synth", 0.42))  # the other reading of "crunch and synth": 0.42 meets the lead guitar's 0.4 on the speaker
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


K_CRASH = 1.0   # seconds to fall 20 dB, as the track's crash does (its long crash took 2.4)


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


# ---------------------------------------------------------------- the renders

def battle(form, edit=None, meter=None):
    call = copied(call_on(form, meter or METER))
    if edit:
        edit(call)
    return F.groove(**call)


def battle_unmastered(form, edit=None, meter=None):
    """The battle on a form up to its master and no further, with the master's settings: the
    master brings a mix under its knee by the mix's own peak, so a row whose peak a part raises
    (M with the crunch synth, the excerpt's loudest bar) would come out quieter everywhere; a
    set's rows are mastered together instead (`master_together`)."""
    call = copied(call_on(form, meter or METER))
    if edit:
        edit(call)
    settings = (call.get("headroom"), call.get("master", 1.25))
    call.update(headroom=None, master=1e-3)   # tanh at a thousandth of its drive: linear to a part in a million
    return F.groove(**call), settings


def master_together(rows):
    """A set's unmastered rows through one master: one division by the loudest row's peak, then
    the master's saturation, so the rows differ only by what changed."""
    (headroom, drive), = {s for _x, s in rows}
    under = max(1.0, max(float(np.max(np.abs(x))) for x, _s in rows) / headroom) if headroom else 1.0
    return [F.sat(x / under, drive) for x, _s in rows]


def map_half(form, edit=None, meter=None, battle_edit=None):
    """The map half on a form: the battle's call (edited first, so the map follows the battle's
    notes), the map's arrangement over it, then the map's own edit."""
    call = copied(call_on(form, meter or METER))
    if battle_edit:
        battle_edit(call)
    kw = dict(call)
    kw.update(P.map_hold_the_line(call))
    kw["drum_gain"] = {}   # the map's drums are its own, at their written gains
    if edit:
        kw = edit(kw, call)
    return F.groove(**kw)


C_FORM = "NNNN B CCCCCCCC NNNN"
L_FORM = "NNNN LLLLLLLL M XX"


def both(*edits):
    def edit(call):
        for e in edits:
            e(call)
    return edit


K_FORM = "K" * 14


def round_five(call):
    """The battle half with every pick: the wrap's crash, both lifts on the crunch synth and the
    lead guitar over the quieter backing guitar, M as it ships with the crunch synth, K on the
    drums in between with the lead guitar added to the walk and its crashes choked."""
    wrap_crash(call)
    lift("C", *CRUNCH_LEAD)(call)
    lift("L", *CRUNCH_LEAD)(call)
    m_crunch(call)
    k_step(2)(call)
    k_crashes()(call)


SETS = [
    {"id": "c", "half": "battle", "title": "The battle's first lift (C): the backing guitar", "note": "Four bars of the riff on its power chords, the turn, the lift's eight bars, back to the riff: the riff on the crunch synth and a second voice in unison over the backing guitar chugging each bar's root on the kick, a crash every four bars, the metal chime and the piano as they were. The second lift is the same.", "rows": [
        ("c0", "As the fourth round had it", "The crunch synth and the lead guitar, the backing guitar where you heard it.", C_FORM, lift("C", *CRUNCH_LEAD, backing=0.62)),
        ("c1", "The backing guitar 6 dB down", "The same with the backing guitar at half its level (the full pair's).", C_FORM, lift("C", *CRUNCH_LEAD)),
        ("c2", "The backing guitar 10 dB down", "The same, the backing guitar further down.", C_FORM, lift("C", *CRUNCH_LEAD, backing=0.62 * 10 ** (-10 / 20.0))),
        ("c3", "The crunch synth and the synth lead", "If “crunch and synth” meant the track's own synth lead in the lead guitar's place: level with it on the speaker, the backing guitar 6 dB down.", C_FORM, lift("C", *CRUNCH_SYNTH)),
    ]},
    {"id": "m", "half": "battle", "title": "The battle's second lift (L) into M", "note": "From the riff into the lift on the crunch synth and the lead guitar, M (the bar down) and into the seven.", "rows": [
        ("m0", "M as it ships", "The chug and the driven bass.", L_FORM, lift("L", *CRUNCH_LEAD)),
        ("m1", "As it ships, with the crunch synth", "The crunch synth on the chug's line an octave up, as the fourth round's M had it (the full pair's).", L_FORM, both(lift("L", *CRUNCH_LEAD), m_crunch)),
    ]},
    {"id": "k", "half": "battle", "title": "K's crashes", "note": "K's fourteen bars on the drums in between with the lead guitar added to the walk; its long crash comes every second bar.", "rows": [
        ("k0", "As the fourth round had it", "The long crash ringing out, about 2.4 seconds to fall 20 dB.", K_FORM, k_step(2)),
        ("k1", "Choked to a second", "Falling 20 dB in a second, as the track's other crashes do (the full pair's).", K_FORM, both(k_step(2), k_crashes())),
        ("k2", "Choked to half a second", "Shorter again.", K_FORM, both(k_step(2), k_crashes(0.5))),
    ]},
]

# Every full render: (key, half, form, the battle's edit). The pair's map half is the fourth
# round's, on the battle half's notes as they were (none of the picks moves a note it follows).
FULLS = [
    ("k14", "battle", FORM_K14, round_five),
    ("k14", "map", FORM_K14, None),
]
PAIR = {"id": "hold_the_line_r5", "title": "Hold The Line, round five", "map": "k14", "battle": "k14",
        "k": "the keyboard solo's first fourteen bars at its slower tempo, the lead guitar with the crunch synth on the walk, K's drums with a pushing kick, eighths on the hat and a china, its crashes choked"}


def level(x, db):
    return F.limit(F.write_level(x, NAME, db))


def render_row(job):
    """One row of a set, in a worker, from its set's seed; read as the track reads its sections."""
    si, ri = job
    F.seed("hold5_" + SETS[si]["id"])
    _rid, _title, _note, form, edit = SETS[si]["rows"][ri]
    with P.Patched(_steps=run_steps):
        return si, ri, battle_unmastered(form, edit)


def full_path(key, half):
    return os.path.join(P.OUT, "hold5_full_%s_%s.wav" % (key, half))


def render_full(i):
    """One full half, in a worker, from the shipped half's seed, at its half's level."""
    key, half, form, edit = FULLS[i]
    if half == "battle":
        F.seed(NAME)
        call = copied(call_on(form, METER))
        edit(call)
        x = level(F.groove(**call), BATTLE_LEVEL)
    else:
        F.seed(NAME + "_map")
        x = level(map_half(form, map_picks, METER, edit), MAP_LEVEL)
    P.write(os.path.basename(full_path(key, half))[:-4], x, aac=False)
    return key, half


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
        full_runs = [pool.submit(render_full, i) for i in (range(len(FULLS)) if "full" in wanted else ())]
        raw = {(si, ri): x for si, ri, x in pool.map(render_row, jobs)}
        for f in full_runs:
            f.result()
    manifest_path = os.path.join(P.OUT, "hold5.json")
    manifest = json.load(open(manifest_path)) if os.path.exists(manifest_path) else {"sets": [], "tracks": [], "seams": []}
    for si, s in enumerate(SETS):
        if s["id"] not in wanted:
            continue
        # One master and one gain for the set, the gain the one that brings its first row to its
        # half's level, so the rows differ only by what changed.
        mastered = master_together([raw[si, ri] for ri in range(len(s["rows"]))])
        gain = 10.0 ** (((BATTLE_LEVEL if s["half"] == "battle" else MAP_LEVEL) - F.mean_level(mastered[0])) / 20.0)
        rows = []
        for ri, (rid, title, note, _form, _edit) in enumerate(s["rows"]):
            x = F.limit(mastered[ri] * gain)
            rows.append({"id": rid, "title": title, "note": note, "file": os.path.basename(P.write("hold5_" + rid, x)),
                         "seconds": round(len(x) / F.SR, 2), "phone_db": P.measure(rid, x)["phone_db"]})
        manifest["sets"] = [e for e in manifest["sets"] if e["id"] != s["id"]] + [{"id": s["id"], "half": s["half"], "title": s["title"], "note": s["note"], "rows": rows}]
        print("%-2s %s" % (s["id"], "  ".join("%s %.1f" % (r["id"], r["phone_db"]) for r in rows)))
    manifest["sets"].sort(key=lambda e: [s["id"] for s in SETS].index(e["id"]))
    if "full" in wanted:
        bpm = F.MUSIC[NAME]["bpm"]
        halves = {(k, h): P.read_wav(full_path(k, h)) for k, h, _f, _e in FULLS}
        m, b = halves[PAIR["map"], "map"], halves[PAIR["battle"], "battle"]
        if len(m) != len(b):
            raise ValueError("the halves are %d and %d samples" % (len(m), len(b)))
        P.write(PAIR["id"] + "_pair", [m, b], kbps=384)
        secs, total, at = sections_of(FORM_K14, METER, bpm, PAIR["k"])
        levels = [P.measure("map", m), P.measure("battle", b)]
        manifest["tracks"] = [{"id": PAIR["id"], "title": PAIR["title"], "new": "both", "bpm": bpm, "length": round(total, 3),
                               "loop_from_bar": 9, "bar_at": [round(float(t), 4) for t in at[:-1]], "sections": secs, "levels": levels}]
        print("%s  map %.1f (phone %.1f)  battle %.1f (phone %.1f)" % (PAIR["id"], levels[0]["mean_db"], levels[0]["phone_db"], levels[1]["mean_db"], levels[1]["phone_db"]))
        manifest["seams"] = []
    with open(manifest_path, "w") as f:
        json.dump(manifest, f, indent=1)
    print(os.path.relpath(manifest_path))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

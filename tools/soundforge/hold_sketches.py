"""Hold The Line's third round as a pair (Ryan, 29 October, on the second round's page):

  both           V and Q stay ("I liked V and Q, put them back. The fill worked fine"), so only J
                 goes: Q's fill lands on the wrap at bar nine, with a crash there as at J's door
                 before. K keeps its slower tempo.
  the battle     K's two reworks again at the solo's tempo, never on the climax's drums: each with
                 K's drums as they were, and with drums between those and the climax's. The first
                 lift keeps its metal chime and piano as they were and takes his pick from the
                 second round (a backing guitar chugging each bar's root wherever the kick hits, a
                 crash every four bars), its riff on two voices in unison, four ways; the second
                 lift takes the same under the crunch synth as it was, then the crunch synth with
                 a second voice in unison, three ways.
  the map half   his picks: X's held walk on the violins, U's lead on the clean guitar, the
                 climax's drone moved from its first set to its second, W on the low note with the
                 roll, the roll up and the cello down (two steps to hear); K as the second round
                 had it, without the cellos.

K's reworks:

  K1  the whole solo in double time: its melody and its walk at half their lengths, one chord a
      bar (Em Cm Bm E(b5) Am F Bm Em), the walk on the crunch synth, the driven bass and the
      chug, the piano's line doubled by the keys' lead.
  K2  the solo's first half as written, the driven bass on the walk and the chug on the chords'
      roots; it ends on the solo's E with the flattened fifth, which V's E minor resolves.

  drums as they were   K's own: the kick on one and three with a push, the snare on three, a
                       long crash every second bar, the splash and the toms before it.
  drums in between     K's own with the kick pushing on the and of two and into the next bar, a
                       ghost on either side of the snare, eighths on the hat with the open hat on
                       the and of four, a china on three every second bar, a little louder.

The full pairs on the switch are K1 and K2 with the drums in between and the map's picks; K's
seams set holds all four battle Ks beside K as it was (without J), cut from full renders the way
the game loops them (the climax's last set to the end, then the wrap on into bar thirteen).
Every other set is an excerpt for A/B, every row the same bars from the same seed at one gain.

    tools/spriter/.venv/bin/python tools/soundforge/hold_sketches.py          # every set and both pairs, then hold3.json beside the pairs (about ten minutes on four cores)
    tools/spriter/.venv/bin/python tools/soundforge/hold_sketches.py c l      # the named sets only (c l w, and full for the pairs and the seams)
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
FORM_K8 = FORM_K16.replace("K" * 16, "K" * 8)    # K reworked to eight bars
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


def diminish(pat):
    """A riff pattern at double speed: every note and rest half as long."""
    out, i = [], 0
    while i < len(pat):
        c, n = pat[i], 1
        tail = "." if c == "." else "-"
        while i + n < len(pat) and pat[i + n] == tail:
            n += 1
        if n % 2:
            raise ValueError("an odd length at step %d of %r" % (i, pat))
        out.append("." * (n // 2) if c == "." else c + "-" * (n // 2 - 1))
        i += n
    return "".join(out)


def from_bar(call, section, bar):
    """A section's run started `bar` bars in: every part and its chords turned round, so an
    excerpt can play a long section's last bars into what follows it."""
    def turn(pat):
        k = 16 * bar % len(pat)
        return pat[k:] + pat[:k]
    for v in call["voices"]:
        if section in v["pat"]:
            v["pat"][section] = turn(v["pat"][section])
    for part in call["drums"].values():
        if section in part:
            part[section] = turn(part[section])
    c = call["chords"][section]
    call["chords"][section] = c[bar % len(c):] + c[:bar % len(c)]


# ---------------------------------------------------------------- the lifts (the battle half)

LIFT_RIFF = "8-.c.8-a.8-.5-.38-.c.8-a.3-.5-.7"   # C E C D C A G C, E C D G A B: both lifts' riff
LEAD_GUITAR = {"mute": False, "cutoff": 2400.0, "clean": True}   # the climax's lead guitar voice
RIFF_VOICES = {
    "sub": {"inst": "sub_bass", "mode": "riff", "hold": 1.0},                                          # the first lift's own
    "bass": {"inst": "bass_real", "mode": "riff", "hold": 1.1, "params": {"drive": 3.5}},              # the driven bass
    "crunch": {"inst": "bass", "mode": "riff", "hold": 1.0, "params": {"drive": 3.5, "cutoff": 800.0}},   # the second lift's own
    "lead": {"inst": "guitar_real", "mode": "riff", "hold": 0.9, "params": LEAD_GUITAR},               # the lead guitar voice
}


def kick_chug(call, section):
    """A backing guitar chugging each bar's root wherever the kick hits: the lifts' syncopation, locked."""
    kick = call["drums"]["kick"][section]
    return "".join(kick.replace("x", r) for r in roots_of(call, section, 4))


def lift_band(call, s):
    """Ryan's pick of the second round (the first lift's second row): a backing guitar chugging
    each bar's root wherever the kick hits, a crash every four bars."""
    add(call, inst="guitar_real", mode="riff", gain=0.62, octave=-1, pat={s: kick_chug(call, s)})
    drums(call, s, crash="x" + "." * 63)


def riff_on(call, s, *pair):
    """The lift's riff on two voices in unison, each (voice, gain), in place of its own voice."""
    strip(call, "sub_bass", s)
    strip(call, "bass", s)
    for name, gain in pair:
        add(call, **dict(RIFF_VOICES[name], gain=gain, pat={s: LIFT_RIFF}))


# ---------------------------------------------------------------- K reworked (the battle half)

def wrap_crash(call):
    """Q's fill lands on the wrap at bar nine, the riff's power chords: a crash there, as at J's
    door before (the track's top stays bare)."""
    drums(call, "A", crash="." * 128 + "x" + "." * 127)


def k_between(call):
    """K's drums between how they were and the climax's: its own kick pushing on the and of two
    and into the next bar, a ghost either side of its snare on three, eighths on the hat with the
    open hat on the and of four, a china on three every second bar, the drums a little up; its
    long crashes, splashes and toms as they were. What a phone plays of it is the cymbals and the
    snare (the first cut, with the kick's pushes and the hat alone, sat 14 dB under K there)."""
    drums(call, "K", kick="x.....x.x.......x.....x.x...x.x.", snare="......o.x......o", hat="x.x.x.x.x.x.x...",
          open="..............x.", china="........x......." + "." * 16)
    call["drum_gain"]["K"] = 1.08


def k_double(call, between=False):
    """K1: the whole solo in double time, the walk the band's riff."""
    walk = diminish(P.part(call, "bass", "K"))
    melody = diminish(P.part(call, "epiano", "K", octave=2))
    call["chords"]["K"] = call["chords"]["K"][::2]   # one chord a bar: Em Cm Bm E(b5) Am F Bm Em
    strip(call, "bass", "K")
    strip(call, "epiano", "K")
    strip(call, "epiano", "K", mode="stab")
    strip(call, "guitar_chord", "K", mode="stab")
    add(call, inst="bass", mode="riff", gain=0.42, hold=1.0, params={"drive": 3.5, "cutoff": 900.0}, pat={"K": walk})
    add(call, inst="bass_real", mode="riff", gain=0.38, hold=1.0, params={"drive": 3.5}, pat={"K": walk})
    add(call, inst="guitar_real", mode="riff", gain=0.6, octave=-1, pat={"K": walk})
    add(call, inst="epiano", mode="riff", gain=0.5, octave=2, hold=1.0, pat={"K": melody})
    add(call, inst="lead", mode="riff", gain=0.28, octave=2, hold=1.0, pat={"K": melody})
    add(call, inst="epiano", mode="stab", gain=0.4, dur=8.0, pat={"K": "x..............."})
    if between:
        k_between(call)


def k_half(call, between=False):
    """K2: the solo's first half as written (its sixteen-bar parts play their first eight bars on
    an eight-bar run), the band under it."""
    add(call, inst="bass_real", mode="riff", gain=0.38, hold=1.0, params={"drive": 3.5}, pat={"K": P.part(call, "bass", "K")})
    add(call, inst="guitar_real", mode="riff", gain=0.6, octave=-1, pat={"K": P.figure("r.r.r.r.r.r.r.r.", roots_of(call, "K", 8))})
    if between:
        k_between(call)


# ---------------------------------------------------------------- the map half
# A map edit takes the map's arguments and the battle call they were built from.

VIOLINS_X = {"inst": "violin_real", "mode": "riff", "gain": 0.175, "octave": 2, "legato": True}   # at the cellos' level on the speaker
CLEAN_GUITAR_U = {"inst": "guitar_real", "mode": "riff", "gain": 0.26, "octave": 1, "hold": 1.5,
                  "params": {"mute": False, "clean": True}}   # at the harp's level on the speaker


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


def w_low(kw, call, roll=False, cello=0.4, roll_gain=0.3):
    """W dropped to a low note: the horn's held B goes, a cello holds B low through both bars with a
    contrabass an octave under it, under the piano's last note and the sub; with `roll`, a soft
    timpani roll on B through the second bar into the climax."""
    strip(kw, "horn_real", "W")
    kw["voices"].append({"inst": "cello_real", "mode": "riff", "gain": cello, "octave": 0, "legato": True, "pat": {"W": "7" + "-" * 31}})
    kw["voices"].append({"inst": "contrabass_real", "mode": "riff", "gain": 0.34, "octave": -1, "legato": True, "pat": {"W": "7" + "-" * 31}})
    if roll:
        timpani(kw, "W", [7], roll_gain, pattern="." * 16 + "x...x...x.x.xxxx")
    return kw


# W's two steps (Ryan: "bring roll volume up, bring cello down"): the roll up 4 and 8 dB, the cello
# down 3 and 6 dB from the second round's; the full pairs take the second.
W_STEPS = [(0.4, 0.3), (0.28, 0.48), (0.2, 0.75)]


def map_round_three(kw, call):
    """The map half with every pick so far: the drone down and moved, X on the violins, U on the
    clean guitar, W low with the roll at its second step; K without the cellos (its walk on the
    ticking guitar, the sub on its roots, a timpani on each bar's one tuned to its root, very
    soft); the map's V and Q as they were."""
    map_drone(kw)
    map_voice(kw, "cello_real", "X", VIOLINS_X)
    map_voice(kw, "harp", "U", CLEAN_GUITAR_U)
    w_low(kw, call, roll=True, cello=W_STEPS[2][0], roll_gain=W_STEPS[2][1])
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
W_FORM = "FFFF WW SSSS"   # the keys' last four bars, by from_bar


def keys_end(call):
    from_bar(call, "F", 12)


def lift(s, *pair):
    """A lift's row: the chug and the crashes, and the riff on `pair` when one is given."""
    def edit(call):
        lift_band(call, s)
        if pair:
            riff_on(call, s, *pair)
    return edit


SETS = [
    {"id": "c", "half": "battle", "title": "The battle's first lift (C)", "note": "Four bars of the riff on its power chords, the turn, the lift's eight bars, back to the riff. Every row but the first has your pick of the second round, a backing guitar chugging each bar's root wherever the kick hits and a crash every four bars, with the metal chime and the piano as they were; the riff on two voices in unison.", "rows": [
        ("c0", "As it ships", "The soft sub alone on the riff.", lambda: battle(C_FORM)),
        ("c1", "Sub and driven bass", "The second round's second row as you heard it.", lambda: battle(C_FORM, lift("C", ("sub", 0.3), ("bass", 0.42)))),
        ("c2", "Sub and crunch synth", "The second lift's voice joining the first's.", lambda: battle(C_FORM, lift("C", ("sub", 0.4), ("crunch", 0.36)))),
        ("c3", "Driven bass and crunch synth", "The sub gone; the two drivers together.", lambda: battle(C_FORM, lift("C", ("bass", 0.38), ("crunch", 0.36)))),
        ("c4", "Driven bass and lead guitar", "The climax's lead guitar voice with the driven bass.", lambda: battle(C_FORM, lift("C", ("bass", 0.38), ("lead", 0.4)))),
    ]},
    {"id": "l", "half": "battle", "title": "The battle's second lift (L)", "note": "From the riff into the lift, the bar down and into the seven. The chug and the crashes under the crunch synth as it was, then the crunch synth with a second voice in unison.", "rows": [
        ("l0", "As it ships", "The crunch synth alone on the riff.", lambda: battle(L_FORM)),
        ("l1", "The chug and the crashes", "The backing guitar on the kick and a crash every four bars under the crunch synth as it was.", lambda: battle(L_FORM, lift("L"))),
        ("l2", "Crunch synth and driven bass", "As the last, the driven bass in unison with the synth.", lambda: battle(L_FORM, lift("L", ("crunch", 0.4), ("bass", 0.36)))),
        ("l3", "Crunch synth and sub", "As the last, the soft sub in unison instead.", lambda: battle(L_FORM, lift("L", ("crunch", 0.4), ("sub", 0.4)))),
        ("l4", "Crunch synth and lead guitar", "As the last, the lead guitar voice in unison instead.", lambda: battle(L_FORM, lift("L", ("crunch", 0.4), ("lead", 0.4)))),
    ]},
    {"id": "w", "half": "map", "title": "The map's keys turn (W): the roll and the cello", "note": "The keys section's last four bars, the turn on the low note with the roll, into the climax's first set. The full pairs take the second step.", "rows": [
        ("w0", "As you heard it", "The second round's: the roll soft, the cello at its first level.", lambda: map_half(W_FORM, lambda kw, c: w_low(map_drone(kw), c, True, *W_STEPS[0]), battle_edit=keys_end)),
        ("w1", "A step", "The roll 4 dB up, the cello 3 dB down.", lambda: map_half(W_FORM, lambda kw, c: w_low(map_drone(kw), c, True, *W_STEPS[1]), battle_edit=keys_end)),
        ("w2", "Two steps", "The roll 8 dB up, the cello 6 dB down.", lambda: map_half(W_FORM, lambda kw, c: w_low(map_drone(kw), c, True, *W_STEPS[2]), battle_edit=keys_end)),
    ]},
]

# Every full render: (key, half, form, the battle's edit). The battle halves are K's seams; K1 and
# K2 in between, each with the map half on its own notes, are the switch's two pairs.
FULLS = [
    ("k0", "battle", FORM_K16, None),
    ("k1a", "battle", FORM_K8, lambda c: k_double(c)),
    ("k1b", "battle", FORM_K8, lambda c: k_double(c, between=True)),
    ("k2a", "battle", FORM_K8, lambda c: k_half(c)),
    ("k2b", "battle", FORM_K8, lambda c: k_half(c, between=True)),
    ("k0", "map", FORM_K16, None),
    ("k1", "map", FORM_K8, lambda c: k_double(c)),
    ("k2", "map", FORM_K8, lambda c: k_half(c)),
]
SEAM_ROWS = {
    "battle": [("k0", "K as it was", "The slow solo as it ships, then V, Q and the wrap: only J gone."),
               ("k1a", "Double time, its drums as they were", "The whole solo at twice the speed on K's own drums."),
               ("k1b", "Double time, its drums in between", "The same with the kick pushing, ghost notes and eighths on the hat (the full pair's)."),
               ("k2a", "First half, its drums as they were", "The solo's first eight bars as written, the band under it, on K's own drums."),
               ("k2b", "First half, its drums in between", "The same with the kick pushing, ghost notes and eighths on the hat (the full pair's).")],
    "map": [("k0", "K as it was", "The slow solo without the cellos: the walk on the ticking guitar, the sub on its roots, the soft timpani."),
            ("k1", "Double time", "The same voices on the solo in double time."),
            ("k2", "First half", "The same voices on the solo's first half.")],
}
PAIRS = [
    {"id": "hold_the_line_k1", "title": "Hold The Line, K in double time", "map": "k1", "battle": "k1b",
     "k": "the keyboard solo in double time at its slower tempo, one chord a bar, the walk on crunch synth, driven bass and chug, the piano and the keys' lead on the melody, K's drums with a pushing kick and eighths on the hat"},
    {"id": "hold_the_line_k2", "title": "Hold The Line, K's first half", "map": "k2", "battle": "k2b",
     "k": "the keyboard solo's first half as written at its slower tempo, the driven bass on the walk, the chug on the roots, K's drums with a pushing kick and eighths on the hat"},
]


def level(x, db):
    return F.limit(F.write_level(x, NAME, db))


def render_row(job):
    """One row of a set, in a worker, from its set's seed; read as the track reads its sections."""
    si, ri = job
    F.seed("hold3_" + SETS[si]["id"])
    with P.Patched(_steps=run_steps):
        return si, ri, SETS[si]["rows"][ri][3]()


def full_path(key, half):
    return os.path.join(P.OUT, "hold3_full_%s_%s.wav" % (key, half))


def render_full(i):
    """One full half, in a worker, from the shipped half's seed, at its half's level."""
    key, half, form, edit = FULLS[i]
    if half == "battle":
        F.seed(NAME)
        call = copied(call_on(form, METER))
        wrap_crash(call)
        if edit:
            edit(call)
        x = level(F.groove(**call), BATTLE_LEVEL)
    else:
        F.seed(NAME + "_map")
        x = level(map_half(form, map_round_three, METER, edit), MAP_LEVEL)
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


def seam(x, form, meter, bpm):
    """The loop's seam as the game plays it: from the climax's last set to the end, then on from bar
    nine (the wrap) into bar thirteen."""
    form, at = bars_of(form, meter, bpm)
    z = form.index("Z")
    return np.concatenate([x[int(round(at[z] * F.SR)):], x[int(round(at[8] * F.SR)):int(round(at[13] * F.SR))]])


def main(argv):
    wanted = argv or [s["id"] for s in SETS] + ["full"]
    os.makedirs(P.OUT, exist_ok=True)
    jobs = [(si, ri) for si, s in enumerate(SETS) if s["id"] in wanted for ri in range(len(s["rows"]))]
    with ProcessPoolExecutor(max_workers=4) as pool:
        full_runs = [pool.submit(render_full, i) for i in (range(len(FULLS)) if "full" in wanted else ())]
        raw = {(si, ri): x for si, ri, x in pool.map(render_row, jobs)}
        for f in full_runs:
            f.result()
    manifest_path = os.path.join(P.OUT, "hold3.json")
    manifest = json.load(open(manifest_path)) if os.path.exists(manifest_path) else {"sets": [], "tracks": [], "seams": []}
    for si, s in enumerate(SETS):
        if s["id"] not in wanted:
            continue
        # One gain for the set, the one that brings its first row to its half's level, so the rows
        # differ only by what changed.
        gain = 10.0 ** (((BATTLE_LEVEL if s["half"] == "battle" else MAP_LEVEL) - F.mean_level(raw[si, 0])) / 20.0)
        rows = []
        for ri, (rid, title, note, _render) in enumerate(s["rows"]):
            x = F.limit(raw[si, ri] * gain)
            rows.append({"id": rid, "title": title, "note": note, "file": os.path.basename(P.write("hold3_" + rid, x)),
                         "seconds": round(len(x) / F.SR, 2), "phone_db": P.measure(rid, x)["phone_db"]})
        manifest["sets"] = [e for e in manifest["sets"] if e["id"] != s["id"]] + [{"id": s["id"], "half": s["half"], "title": s["title"], "note": s["note"], "rows": rows}]
        print("%-2s %s" % (s["id"], "  ".join("%s %.1f" % (r["id"], r["phone_db"]) for r in rows)))
    manifest["sets"].sort(key=lambda e: [s["id"] for s in SETS].index(e["id"]))
    if "full" in wanted:
        bpm = F.MUSIC[NAME]["bpm"]
        halves = {(k, h): P.read_wav(full_path(k, h)) for k, h, _f, _e in FULLS}
        forms = {(k, h): f for k, h, f, _e in FULLS}
        manifest["tracks"] = []
        for p in PAIRS:
            m, b = halves[p["map"], "map"], halves[p["battle"], "battle"]
            if len(m) != len(b):
                raise ValueError("%s: the halves are %d and %d samples" % (p["id"], len(m), len(b)))
            P.write(p["id"] + "_pair", [m, b], kbps=384)
            secs, total, at = sections_of(FORM_K8, METER, bpm, p["k"])
            levels = [P.measure("map", m), P.measure("battle", b)]
            manifest["tracks"].append({"id": p["id"], "title": p["title"], "new": "both", "bpm": bpm, "length": round(total, 3),
                                       "loop_from_bar": 9, "bar_at": [round(float(t), 4) for t in at[:-1]], "sections": secs, "levels": levels})
            print("%s  map %.1f (phone %.1f)  battle %.1f (phone %.1f)" % (p["id"], levels[0]["mean_db"], levels[0]["phone_db"], levels[1]["mean_db"], levels[1]["phone_db"]))
        manifest["seams"] = []
        for half, sid, title, note in (("battle", "kb", "The battle's loop: K into V, Q and the wrap",
                                        "From the climax's last set through the breath, K, V and Q's fill, then the wrap into bar thirteen, as the game loops it."),
                                       ("map", "km", "The map's loop: K without the cellos",
                                        "The same bars on the map half.")):
            rows = []
            for key, rtitle, rnote in SEAM_ROWS[half]:
                cut = seam(halves[key, half], forms[key, half], METER, bpm)
                rows.append({"id": "%s_%s" % (key, half), "title": rtitle, "note": rnote, "seconds": round(len(cut) / F.SR, 2),
                             "file": os.path.basename(P.write("hold3_%s_%s" % (key, half), cut))})
            manifest["seams"].append({"id": sid, "half": half, "title": title, "note": note, "rows": rows})
    with open(manifest_path, "w") as f:
        json.dump(manifest, f, indent=1)
    print(os.path.relpath(manifest_path))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

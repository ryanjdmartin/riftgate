"""Hold The Line's second round as a pair (Ryan, 29 October, on the pair page):

  the map half   the drone comes down, and moves from the climax's first set to its second
                 (R had nothing noticeable added); X's held walk on something other than the
                 cellos, just for fun; U's lead on another voice than the harp; W dropped to a low
                 note; K without the cellos, a very subtle timpani perhaps, after the battle's K.
  the battle     the quiet sections to make more sense now the calm lives in the map half; the
                 first lift (C) in a couple of variations, more metal and rock (a backing guitar,
                 other voices on the riff, the chime changed); the second (L) a bit more rock;
                 the two perhaps merged into repeats of one another; K, the worst offender for the
                 fight's hype and too long, reworked into the loop's driver in place of J.
  both           the loop without J.

So the shipped form loses J, and with it the two bars that only led into J (V, the solo's second
breath at its slower tempo, and Q, the fill before the descent): K drives straight into the wrap
at bar nine, at the track's own tempo, and a crash lands the wrap. K's two reworks, each a full
pair on the switch with the map's changes below (the drone down and moved, K without the cellos):

  K1  the whole solo in double time: its melody and its walk at half their lengths, one chord a
      bar (Em Cm Bm E(b5) Am F Bm Em), the walk on the crunch synth, the driven bass and the
      chug, the piano's line doubled by the keys' lead, the climax's drums, a fill into the wrap.
  K2  the solo's first half at the track's tempo with the band driving under it: the melody and
      the walk as written, the driven bass on the walk, the chug on the chords' roots, the same
      drums; it ends on the solo's E with the flattened fifth, which the wrap resolves.

Everything else is an excerpt for A/B, every row of a set the same bars from the same seed at the
same gain, so switching rows keeps the place and a row that adds a voice is louder by it: the
lifts C and L and their merges on the battle half, X, U, W and R on the map half, and each K's
seam (the climax's last set to the end, then the wrap on into bar thirteen, cut from the full
render the way the game loops it).

    tools/spriter/.venv/bin/python tools/soundforge/hold_sketches.py          # every set and both pairs, then the round's manifest (round2.json beside the pairs)
    tools/spriter/.venv/bin/python tools/soundforge/hold_sketches.py c u      # the named sets only (c l m x u w r, and full for the pairs and the seams)
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
SHIPPED_METER = dict(F.MUSIC[NAME]["meter"])
NEW_FORM = "AAAAAAAAAAAAAAAAB CCCCCCCC NNNN LLLLLLLL M XXXXXXXXXXXX UUUUUUUU FFFFFFFFFFFFFFFF WW SSSSSSSS RRRRRRRR ZZZZZZZZ Y KKKKKKKK"
NEW_METER = {"X": 14}   # K at the track's own tempo; V gone
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


def regain(call, inst, section, gain, mode="riff"):
    """A section's matching voices at another gain: the section split off into a voice of its own."""
    for v in list(call["voices"]):
        if matches(v, inst, section, mode, {}):
            call["voices"].append(dict(v, gain=gain, pat={section: v["pat"].pop(section)}))


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


def kick_chug(call, section):
    """A backing guitar chugging each bar's root wherever the kick hits: the lifts' syncopation, locked."""
    kick = call["drums"]["kick"][section]
    return "".join(kick.replace("x", r) for r in roots_of(call, section, 4))


def lift_backing(call, s):
    """C1: the driven bass carries the riff over the soft sub; a backing guitar chugs the roots on the kick; a crash every four bars."""
    regain(call, "sub_bass", s, 0.3)
    add(call, inst="bass_real", mode="riff", gain=0.42, hold=1.1, params={"drive": 3.5}, pat={s: LIFT_RIFF})
    add(call, inst="guitar_real", mode="riff", gain=0.62, octave=-1, pat={s: kick_chug(call, s)})
    drums(call, s, crash="x" + "." * 63)


def lift_lead(call, s):
    """C2: the climax's lead guitar voice carries the riff an octave up with the driven bass under it; a
    backing guitar rings each bar's chord in place of the piano's stabs; the chime half as busy, an octave down."""
    regain(call, "sub_bass", s, 0.3)
    add(call, inst="guitar_real", mode="riff", gain=0.45, octave=1, hold=0.9, params=LEAD_GUITAR, pat={s: LIFT_RIFF})
    add(call, inst="bass_real", mode="riff", gain=0.4, hold=1.1, params={"drive": 3.5}, pat={s: LIFT_RIFF})
    strip(call, "epiano", s, mode="stab")
    add(call, inst="guitar_hold", mode="stab", gain=0.55, dur=16, pat={s: "x..............."})
    strip(call, "chime_metal", s, mode="chord")
    add(call, inst="chime_metal", mode="chord", octave=1, gain=0.24, echo=(3, 0.25, 2), dur=3.2, pat={s: "0...2...1...3...0...3...2...1..."})
    drums(call, s, crash="x" + "." * 63)


def lift_unison(call, s):
    """C3: the crunch synth and a palm-muted chug play the riff in unison over the soft sub; the piano
    takes the chime's figure; a china every other bar."""
    regain(call, "sub_bass", s, 0.3)
    if not any(matches(v, "bass", s, "riff", {}) for v in call["voices"]):
        add(call, inst="bass", mode="riff", gain=0.42, hold=1.0, params={"drive": 3.5, "cutoff": 1100.0}, pat={s: LIFT_RIFF})
    add(call, inst="guitar_real", mode="riff", gain=0.55, octave=-1, pat={s: LIFT_RIFF})
    figure = P.part(call, "chime_metal", "C", mode="chord")
    strip(call, "chime_metal", s, mode="chord")
    add(call, inst="epiano", mode="chord", octave=2, gain=0.36, dur=1.6, pat={s: figure})
    drums(call, s, china="." * 30 + "x.", crash="x" + "." * 63)


def lift_rock(call, s):
    """L1: the backing guitar chugs the roots on the kick and the driven bass sits an octave under the
    crunch synth's riff; a crash every four bars."""
    add(call, inst="bass_real", mode="riff", gain=0.36, hold=1.1, octave=-1, params={"drive": 3.5}, pat={s: LIFT_RIFF})
    add(call, inst="guitar_real", mode="riff", gain=0.62, octave=-1, pat={s: kick_chug(call, s)})
    drums(call, s, crash="x" + "." * 63)


def lift_rock_lead(call, s):
    """L2: L1, and the lead guitar doubles the riff an octave up."""
    lift_rock(call, s)
    add(call, inst="guitar_real", mode="riff", gain=0.42, octave=1, hold=0.9, params=LEAD_GUITAR, pat={s: LIFT_RIFF})


def repeat_section(call, src, dst):
    """dst plays what src plays: every voice's, drum's and pad's src part copied to dst, and dst's own
    parts kept where src has none."""
    for v in call["voices"]:
        if src in v["pat"]:
            v["pat"][dst] = v["pat"][src]
    for part in call["drums"].values():
        if src in part:
            part[dst] = part[src]
    for p in call["pad"]:
        if src in p.get("sections", "") and dst not in p["sections"]:
            p["sections"] += dst


def merge_on_c(call):
    """M1: both lifts are C1; the second keeps the crunch synth on the riff as well, so it adds a voice."""
    repeat_section(call, "C", "L")
    lift_backing(call, "C")
    lift_backing(call, "L")


def merge_on_l(call):
    """M2: both lifts are L1 wearing C's chime and choir; the second adds the lead guitar on the riff."""
    repeat_section(call, "L", "C")
    strip(call, "sub_bass", "C")
    for v in call["voices"]:
        if v["inst"] == "chime_metal" and "C" in v["pat"]:
            v["pat"]["L"] = v["pat"]["C"]
    for p in call["pad"]:
        if "C" in p.get("sections", "") and "L" not in p["sections"]:
            p["sections"] += "L"
    lift_rock(call, "C")
    lift_rock_lead(call, "L")


# ---------------------------------------------------------------- K as the loop's driver (the battle half)

def driving(call, s, bars=8):
    """The climax's first-set drums under a section, a crash every two bars, a china on three every
    other bar and a tom fill in its last bar into the wrap; everything the section had dropped."""
    for part in call["drums"].values():
        part.pop(s, None)
    fill = 16 * (bars - 1)
    drums(call, s, kick="x.xx..x.x.xx..x.", snare="....x.......x...", hat="x.x.x.x.x.x.x.x.",
          china="........x......." + "." * 16, crash="x" + "." * 31,
          tom="." * fill + "....x.x.xx.x.x..", tom2="." * fill + "......x.....x.xx")
    call["drum_gain"][s] = 1.15
    # The wrap lands on the riff's power chords at bar nine: a crash there, as at every door (the
    # track's top stays bare).
    drums(call, "A", crash="." * 128 + "x" + "." * 127)


def k_double(call):
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
    driving(call, "K")


def k_half(call):
    """K2: the solo's first half as written (its sixteen-bar parts play their first eight bars on an
    eight-bar run), at the track's tempo, the band driving under it."""
    add(call, inst="bass_real", mode="riff", gain=0.38, hold=1.0, params={"drive": 3.5}, pat={"K": P.part(call, "bass", "K")})
    add(call, inst="guitar_real", mode="riff", gain=0.6, octave=-1, pat={"K": P.figure("r.r.r.r.r.r.r.r.", roots_of(call, "K", 8))})
    driving(call, "K")


# ---------------------------------------------------------------- the map half
# A map edit takes the map's arguments and the battle call they were built from.

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
    (semitones above E), one drum a note."""
    for semis in sorted(set(notes)):
        kw["kit"]["timp%d" % semis] = ([tuned_timpani(semis)], gain)
        kw["drums"]["timp%d" % semis] = {section: "".join(pattern if n == semis else "." * len(pattern) for n in notes)}


def map_drone(kw, call=None):
    """The drone 4 dB down (Ryan: it needs to come down), out of the climax's first set and
    arriving with its second (his idea for R, where nothing noticeable was added)."""
    for p in kw["pad"]:
        if p["inst"] == "sweep" and p.get("chord"):
            p.update(gain=0.25, sections="ANRZ")
    return kw


def map_round_two(kw, call):
    """The map half for the round's full pairs: the drone down and moved; K without the cellos,
    its walk on the ticking guitar, the sub on its roots, a timpani on each bar's one tuned to the
    bar's root, very soft; no V, Q or J to play."""
    map_drone(kw)
    strip(kw, "cello_real", "K")
    kw["voices"].append(dict(P.TICKING, gain=0.22, pat={"K": P.part(call, "bass", "K")}))
    kw["voices"].append({"inst": "sub_bass", "mode": "riff", "gain": 0.34, "legato": True, "pat": {"K": P.roots(call, "K")}})
    chords = call["chords"]["K"]
    timpani(kw, "K", [chords[b % len(chords)][0] % 12 for b in range(8)], 0.28)
    return kw


def map_voice(kw, inst, section, new):
    """The map's voice for a section swapped: the section moved off its voice onto `new`."""
    for v in kw["voices"]:
        if v["inst"] == inst and section in v["pat"]:
            kw["voices"].append(dict(new, pat={section: v["pat"].pop(section)}))
            return kw
    raise KeyError("no %s plays %s" % (inst, section))


def w_low(kw, call, roll=False):
    """W dropped to a low note: the horn's held B goes, a cello holds B low through both bars with a
    contrabass an octave under it, under the piano's last note and the sub; with `roll`, a soft
    timpani roll on B through the second bar into the climax."""
    strip(kw, "horn_real", "W")
    kw["voices"].append({"inst": "cello_real", "mode": "riff", "gain": 0.4, "octave": 0, "legato": True, "pat": {"W": "7" + "-" * 31}})
    kw["voices"].append({"inst": "contrabass_real", "mode": "riff", "gain": 0.34, "octave": -1, "legato": True, "pat": {"W": "7" + "-" * 31}})
    if roll:
        timpani(kw, "W", [7], 0.3, pattern="." * 16 + "x...x...x.x.xxxx")
    return kw


# ---------------------------------------------------------------- the renders

def battle(form, edit=None, meter=None):
    call = copied(call_on(form, meter or SHIPPED_METER))
    if edit:
        edit(call)
    return F.groove(**call)


def map_half(form, edit=None, meter=None, battle_edit=None):
    """The map half on a form: the battle's call (edited first, so the map follows the battle's
    notes), the map's arrangement over it, then the map's own edit."""
    call = copied(call_on(form, meter or SHIPPED_METER))
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
M_FORM = "NNNN B CCCCCCCC NNNN LLLLLLLL M XX"
X_FORM = "XXXXXXXXXXXX"
U_FORM = "UUUUUUUU"
W_FORM = "FFFF WW SSSS"   # the keys' last four bars, by from_bar
R_FORM = "SSSSSSSS RRRRRRRR"


def keys_end(call):
    from_bar(call, "F", 12)


SETS = [
    {"id": "c", "half": "battle", "title": "The battle's first lift (C)", "note": "Four bars of the riff on its power chords, the turn, the lift's eight bars, back to the riff.", "rows": [
        ("c0", "As it ships", "The soft sub on the riff, the piano off the beat, the metal chime, the choir.",
         lambda: battle(C_FORM)),
        ("c1", "Backing guitar", "The driven bass carries the riff over the sub, a backing guitar chugs each bar's root wherever the kick hits, a crash every four bars.",
         lambda: battle(C_FORM, lambda c: lift_backing(c, "C"))),
        ("c2", "Lead guitar on the riff", "The climax's lead guitar voice carries the riff an octave up over the driven bass; a guitar rings each bar's chord where the piano stabbed; the chime half as busy and an octave down.",
         lambda: battle(C_FORM, lambda c: lift_lead(c, "C"))),
        ("c3", "Crunch and chug in unison", "The crunch synth and a palm-muted chug play the riff together over the sub; the piano takes the chime's figure; a china every other bar.",
         lambda: battle(C_FORM, lambda c: lift_unison(c, "C"))),
    ]},
    {"id": "l", "half": "battle", "title": "The battle's second lift (L)", "note": "From the riff into the lift, the bar down and into the seven.", "rows": [
        ("l0", "As it ships", "The crunch synth on the riff, the piano off the beat.",
         lambda: battle(L_FORM)),
        ("l1", "A bit more rock", "A backing guitar chugs the roots on the kick, the driven bass an octave under the riff, a crash every four bars.",
         lambda: battle(L_FORM, lambda c: lift_rock(c, "L"))),
        ("l2", "More rock, lead on top", "As the last, and the lead guitar doubling the riff an octave up.",
         lambda: battle(L_FORM, lambda c: lift_rock_lead(c, "L"))),
    ]},
    {"id": "m", "half": "battle", "title": "The two lifts as repeats", "note": "Both lifts in their places with the riff between them, into the seven. The second adds a voice, so the repeat still changes by what plays.", "rows": [
        ("m0", "As it ships", "Two different lifts: the sub's with the chime and the choir, then the crunch synth's.",
         lambda: battle(M_FORM)),
        ("m1", "Both on the backing guitar", "Both lifts as the backing guitar's (C1); the second adds the crunch synth on the riff.",
         lambda: battle(M_FORM, merge_on_c)),
        ("m2", "Both on the crunch synth", "Both lifts as the rocked second lift (L1) wearing the first's chime and choir; the second adds the lead guitar on the riff.",
         lambda: battle(M_FORM, merge_on_l)),
    ]},
    # A swapped voice is level-matched to the one it replaces, through the phone model over the
    # bars it plays, so a row is heard for its colour and not its level.
    {"id": "x", "half": "map", "title": "The map's seven (X): the held walk", "note": "The 7/8 riff's twelve bars; the walk down E D C sharp C holds through the second half. Each voice at the cellos' level on the speaker.", "rows": [
        ("x0", "Cellos", "As the map half has it.",
         lambda: map_half(X_FORM)),
        ("x1", "Horn", "A soft horn holds the walk.",
         lambda: map_half(X_FORM, lambda kw, c: map_voice(kw, "cello_real", "X", {"inst": "horn_real", "mode": "riff", "gain": 0.11, "octave": 1, "legato": True}))),
        ("x2", "Violins", "The violins hold it an octave higher.",
         lambda: map_half(X_FORM, lambda kw, c: map_voice(kw, "cello_real", "X", {"inst": "violin_real", "mode": "riff", "gain": 0.175, "octave": 2, "legato": True}))),
        ("x3", "Clean guitar, let ring", "The mechanical guitar unmuted and clean, each note ringing its bar.",
         lambda: map_half(X_FORM, lambda kw, c: map_voice(kw, "cello_real", "X", {"inst": "guitar_real", "mode": "riff", "gain": 0.135, "octave": 1, "legato": True, "params": {"mute": False, "clean": True, "damp": 0.9985}}))),
    ]},
    {"id": "u", "half": "map", "title": "The map's unison (U): the lead", "note": "The unison riff's eight bars in threes and twos. Each voice at the harp's level on the speaker.", "rows": [
        ("u0", "Harp", "As the map half has it.",
         lambda: map_half(U_FORM)),
        ("u1", "Pizzicato", "Plucked strings, dark and short.",
         lambda: map_half(U_FORM, lambda kw, c: map_voice(kw, "harp", "U", {"inst": "pizz", "mode": "riff", "gain": 0.72, "octave": 1}))),
        ("u2", "Clean bass", "The clean bass's tapped tone, Full Bore's melody voice.",
         lambda: map_half(U_FORM, lambda kw, c: map_voice(kw, "harp", "U", {"inst": "bass_clean", "mode": "riff", "gain": 0.205, "octave": 1, "hold": 1.0}))),
        ("u3", "Tine piano", "The piano that carries the riff elsewhere in the map half.",
         lambda: map_half(U_FORM, lambda kw, c: map_voice(kw, "harp", "U", {"inst": "epiano", "mode": "riff", "gain": 0.33, "octave": 2, "hold": 1.4}))),
        ("u4", "Clean guitar, let ring", "The mechanical guitar unmuted and clean, over the muted one.",
         lambda: map_half(U_FORM, lambda kw, c: map_voice(kw, "harp", "U", {"inst": "guitar_real", "mode": "riff", "gain": 0.26, "octave": 1, "hold": 1.5, "params": {"mute": False, "clean": True}}))),
    ]},
    {"id": "w", "half": "map", "title": "The map's keys turn (W)", "note": "The keys section's last four bars, the turn's two, into the climax's first set (its drone moved off, as in the round's full pairs).", "rows": [
        ("w0", "As it is", "The piano's last note, a horn holding it through both bars, the sub.",
         lambda: map_half(W_FORM, map_drone, battle_edit=keys_end)),
        ("w1", "A low note", "The horn goes; a cello holds the note low through both bars with a contrabass an octave under it.",
         lambda: map_half(W_FORM, lambda kw, c: w_low(map_drone(kw), c), battle_edit=keys_end)),
        ("w2", "A low note and a roll", "As the last, with a soft timpani roll through the second bar into the climax.",
         lambda: map_half(W_FORM, lambda kw, c: w_low(map_drone(kw), c, roll=True), battle_edit=keys_end)),
    ]},
    {"id": "r", "half": "map", "title": "The map's climax, first and second sets (S, R)", "note": "Sixteen bars: does the second set bring something you hear?", "rows": [
        ("r0", "As it is", "The drone under both sets at its first level.",
         lambda: map_half(R_FORM)),
        ("r1", "The drone moved", "The drone 4 dB down, out of the first set and arriving with the second.",
         lambda: map_half(R_FORM, map_drone)),
    ]},
]

# The two full pairs on the round's form, K reworked each way, and their seams.
PAIRS = [
    {"id": "hold_the_line_k1", "title": "Hold The Line, K in double time", "edit": k_double,
     "k": "the loop's driver: the whole solo in double time, one chord a bar, the walk on crunch synth, driven bass and chug, the piano and the keys' lead on the melody, the climax's drums, a fill into the wrap"},
    {"id": "hold_the_line_k2", "title": "Hold The Line, K's first half", "edit": k_half,
     "k": "the loop's driver: the solo's first half as written at the track's tempo, the driven bass on the walk, the chug on the roots, the climax's drums, a fill into the wrap"},
]


def render_row(job):
    """One row of a set, in a worker, from its set's seed; read as the track reads its sections."""
    si, ri = job
    F.seed("hold2_" + SETS[si]["id"])
    with P.Patched(_steps=run_steps):
        return si, ri, SETS[si]["rows"][ri][3]()


def render_full(job):
    """One half of a full pair, in a worker, from the shipped half's seed, at its level."""
    pi, which = job
    p = PAIRS[pi]
    if which == "battle":
        F.seed(NAME)
        x, db = battle(NEW_FORM, p["edit"], NEW_METER), BATTLE_LEVEL
    else:
        F.seed(NAME + "_map")
        x, db = map_half(NEW_FORM, map_round_two, NEW_METER, p["edit"]), MAP_LEVEL
    P.write("%s_%s" % (p["id"], which), F.limit(F.write_level(x, NAME, db)), aac=False)
    return pi, which


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
    fulls = [(pi, w) for pi in range(len(PAIRS)) for w in ("battle", "map")] if "full" in wanted else []
    with ProcessPoolExecutor(max_workers=4) as pool:
        full_runs = [pool.submit(render_full, j) for j in fulls]
        raw = {}
        for si, ri, x in pool.map(render_row, jobs):
            raw[si, ri] = x
        for f in full_runs:
            f.result()
    manifest_path = os.path.join(P.OUT, "round2.json")
    manifest = json.load(open(manifest_path)) if os.path.exists(manifest_path) else {"sets": [], "tracks": [], "seams": []}
    for si, s in enumerate(SETS):
        if s["id"] not in wanted:
            continue
        # One gain for the set, the one that brings its first row (as it ships, or as it is) to
        # its half's level, so the rows differ only by what changed.
        gain = 10.0 ** (((BATTLE_LEVEL if s["half"] == "battle" else MAP_LEVEL) - F.mean_level(raw[si, 0])) / 20.0)
        rows = []
        for ri, (rid, title, note, _render) in enumerate(s["rows"]):
            x = F.limit(raw[si, ri] * gain)
            rows.append({"id": rid, "title": title, "note": note, "file": os.path.basename(P.write("hold2_" + rid, x)),
                         "seconds": round(len(x) / F.SR, 2), "phone_db": P.measure(rid, x)["phone_db"]})
        manifest["sets"] = [e for e in manifest["sets"] if e["id"] != s["id"]] + [{"id": s["id"], "half": s["half"], "title": s["title"], "note": s["note"], "rows": rows}]
        print("%-2s %s" % (s["id"], "  ".join("%s %.1f" % (r["id"], r["phone_db"]) for r in rows)))
    manifest["sets"].sort(key=lambda e: [s["id"] for s in SETS].index(e["id"]))
    if fulls:
        bpm = F.MUSIC[NAME]["bpm"]
        manifest["tracks"], seams = [], {"battle": [], "map": []}
        shipped = {"battle": P.read_wav(os.path.join(P.AUDIO, NAME + ".wav")), "map": P.read_wav(os.path.join(P.OUT, "hold_the_line_map.wav"))}
        for half in ("battle", "map"):
            x = seam(shipped[half], SHIPPED_FORM, SHIPPED_METER, bpm)
            seams[half].append({"id": "k0_" + half, "title": "As it ships" if half == "battle" else "As it is",
                                "note": "The breath, the slow solo, its breath, the fill and the descent, then the wrap.",
                                "file": os.path.basename(P.write("hold2_k0_" + half, x)), "seconds": round(len(x) / F.SR, 2)})
        for p in PAIRS:
            m, b = (P.read_wav(os.path.join(P.OUT, "%s_%s.wav" % (p["id"], w))) for w in ("map", "battle"))
            if len(m) != len(b):
                raise ValueError("%s: the halves are %d and %d samples" % (p["id"], len(m), len(b)))
            P.write(p["id"] + "_pair", [m, b], kbps=384)
            secs, total, at = sections_of(NEW_FORM, NEW_METER, bpm, p["k"])
            levels = [P.measure("map", m), P.measure("battle", b)]
            manifest["tracks"].append({"id": p["id"], "title": p["title"], "new": "both", "bpm": bpm, "length": round(total, 3),
                                       "loop_from_bar": 9, "bar_at": [round(float(t), 4) for t in at[:-1]], "sections": secs, "levels": levels})
            k = p["id"][-2:]
            for half, x in (("battle", b), ("map", m)):
                cut = seam(x, NEW_FORM, NEW_METER, bpm)
                seams[half].append({"id": "%s_%s" % (k, half), "title": p["title"].split(", ")[1], "note": p["k"].split(": ", 1)[1].capitalize() + ".",
                                    "file": os.path.basename(P.write("hold2_%s_%s" % (k, half), cut)), "seconds": round(len(cut) / F.SR, 2)})
            print("%s  map %.1f (phone %.1f)  battle %.1f (phone %.1f)" % (p["id"], levels[0]["mean_db"], levels[0]["phone_db"], levels[1]["mean_db"], levels[1]["phone_db"]))
        manifest["seams"] = [
            {"id": "kb", "half": "battle", "title": "The battle's loop without J: K as the driver", "note": "From the climax's last set through the breath and K, then the wrap into bar thirteen, as the game loops it.", "rows": seams["battle"]},
            {"id": "km", "half": "map", "title": "The map's loop without J: K without the cellos", "note": "The same bars on the map half: K's walk on the ticking guitar, the sub on its roots, a soft timpani on each bar's root.", "rows": seams["map"]},
        ]
    with open(manifest_path, "w") as f:
        json.dump(manifest, f, indent=1)
    print(os.path.relpath(manifest_path))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

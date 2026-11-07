"""Hold The Line's twenty-first round as a pair (Ryan, 7 November, on the twentieth): X's riff written out,
K on the crunch synth, W's fill built to the triplets.

  "Write out the X riff for me, it doesn't sound like what I intended. Only the instruments playing the riff
  should be using the quarter tones. K - can I hear crunch synth with the synth-lead-octave-up option? And
  crunch synth with plucked string, but the plucked string down like 3db? W - the 'basses alone' option
  actually sounds fine now with the 6 beats. Hilariously, your drum solo is TOO intense now, it goes at
  speeds that sounds unrealistic. The implementation of the new triplets are superb, but the speeds that you
  start the fill at, those should be what it ends at. Mostly just because a double-kick quadruplet sounds
  just like noise on the phone speaker, not because it's necessarily written badly. Build to the triplets.
  Also, keep those triplets in mind for existing or future drum parts, theyre awesome. The other common drum
  pattern we're missing in general is the sixteenth note descending doubles pattern, as in the famous Phil
  Collins In the Air Tonight fill."

X's riff is written out on the pair page for his marks, and heard alone over the kit (x_alone) in
quarter-tones as the pair has it, with the second pass keeping its A (X_RIFF_QA) and as written; only the
riff's voices bend, as before. K's walk on the crunch synth as it shipped, beside the plucked string 3 dB
down (K21_PAIR, the pair's) or the synth lead an octave up. W's held notes on the basses alone (his pick),
its fill building to Bonham's triplets and ending on them (W_FILL_BUILD, the pair's) or through the
descending doubles down four toms (W_FILL_DOUBLES, with two toms from their own seed, W_TOMS); the figures
are pair_sketches' bonham_triplets and descending_doubles, for any track's fills.

The twentieth round's, kept: X's riff in quarter-tones on every voice that plays it (X_RIFF_Q), the held
line over it in semitones; W one bar of six beats at twelve steps a beat (METER), its notes held two
beats; the map's W on the same bar, its low strings held through and its timpani's roll over the last
four beats; the map's M with L's tine piano on its line (map_m_tine). Its options stay in the code: F's
synth holding W's notes (W_SYNTH), its fill (W_FILL), K's other walks (K_BASSES) and the synth lead at
the plucked string's octave (K_LEADS).

The nineteenth round's, kept: the upper Omnific's power chords through X, U, W, the climax and Y
(UPPER_SECTIONS); N twice through on the keys lead's power chords an octave under, in both halves
(N_BARS); the lifts on their one bass; K's walk off the Omnific; the map's L and M on a clean finger bass
(LM_FINGERS) and U's sub walking its riff (U_BASS).

The eighteenth round's, kept: the power chords one bass into one amp ("Keep the one bass, one-amp").

The seventeenth round's, kept: every Omnific part on real_bass.py's DIRTY drive at the modern
drive's level (DIRTY_LEVEL; "that's what that voice needs to sound like everywhere it's used"), the
lifts' fingers on the modern drive; K's plucked string in tune. Its set of one upper note in the
power chords' place (the octave, the fifth, a perfect fourth, the third along E Phrygian) is off the
page, its voices kept in AN_VOICES.

The sixteenth round's, kept: the Omnific's power chords over the low roots in A's back half and N,
and in B and M with them ("Make sure B and M keep the new voices too"), B's chug hit at their level;
the first lift without its backing guitar, the second's 3 dB up, its riff under the keys lead. The
map half is as the thirteenth round settled it ("Map lifts should keep soft sub").

The fifteenth round's, kept: the drone 3 dB up in A and N, the low fifths gone.

The fourteenth round's, kept:

  the bass       "Omnific low for everything except C, L, F": an active bass near the bridge into a
                 modern prog drive (real_bass.py), an octave down on the roots, in every voice that
                 carried the bass (the driven bass's parts, the crunch synth's in M, K's walk and V)
                 but the lifts' and F's punchy sub, which stays as it ships.
  the lifts      "Fingers for C and L, on the upper octave, just the single instrument": each lift's
                 riff on the fingers into the same drive at its written octave, the synth lead and
                 the lead guitar out.
  the chug       "I don't want to use the chug in unison lines at all (M, X, U, W, Climax, Y, V).
                 Just only as the rhythm where it appears already": the palm-muted chug on A's, B's
                 and N's power chords and as the lifts' backing alone, 3 dB down in A and N.

Kept from the earlier rounds: the
loop without J, V and Q kept, Q's fill landing on the wrap with a crash; the lifts' crashes every
four bars and the backing guitar on the kick; K's first eight bars at its slower tempo on the drums
in between, the plucked string beside the bass on its walk 3 dB down, its long crash choked to a
second and a half; the map half minimal (Ryan, 30 October: "in general the map tracks need to be
minimalist"), its lifts' riff on the soft sub and the tine piano.

The full pair on the switch takes every pick. The set's rows are the same bars from the same seed
through one master at one gain.

    tools/spriter/.venv/bin/python tools/soundforge/hold_sketches.py          # the sets and the pair, then hold21.json beside the pairs (about five minutes on four cores)
    tools/spriter/.venv/bin/python tools/soundforge/hold_sketches.py hx       # the named sets only (hx, hk, hw, and full for the pair)
"""
import json
import os
import sys
import zlib
from concurrent.futures import ProcessPoolExecutor

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import real_bass  # noqa: E402,F401  (the real basses' voice)
import pair_sketches as P  # noqa: E402

NAME = "music_hold_the_line"
SHIPPED_FORM = F.MUSIC[NAME]["form"]
METER = dict(F.MUSIC[NAME]["meter"])            # the seven in 7/8, K and V at the solo's slower tempo (Ryan, 30 October: "keep the tempo drop")
# W in six beats, one bar of twelve steps a beat so a fill can ride sixteenths and sextuplets alike (Ryan, 6
# November: "this bit is like 2 beats too long, it only needs 6, not 8 - 2 beats of fading held notes, and 4
# of drum fills"); both halves, one timeline.
METER["W"] = (72, 1.0 / 3.0)
FORM_K16 = SHIPPED_FORM.replace(" JJ", "")       # the loop without J: Q's fill into the wrap
K_BARS = 8   # K's first eight bars (Ryan, 30 October: "the first 14 bars"; 2 November: "chop 4 more bars off the end of K", then "add one more bar back"; 3 November, of eleven, twelve and eight: "The 8 bars is perfect")


def k_form(bars=K_BARS):
    """The loop without J, K cut to its first `bars` bars."""
    return FORM_K16.replace("K" * 16, "K" * bars)


# N played twice through in both halves (Ryan, 6 November, of the eighteenth round's set: "N: go with 'Twice, on
# the keys lead'"), the map's N with it: the halves keep one timeline.
N_BARS = 8
FORM_K = k_form().replace("N" * 4, "N" * N_BARS).replace(" WW ", " W ")
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


# The walk's second voice in K beside the crunch synth (Ryan, 2 November: "can I hear plucked guitar
# instead of what I think is the lead guitar voice?"): the plucked string an octave up, as the
# map's walk had it, 3 dB under the lead guitar's level on a phone (3 November: "Plucked string is
# good for K, but bring it down like 3 db"; the lead guitar's level was 0.77).
K_PLUCK = {"inst": "pluck", "mode": "riff", "octave": 1, "hold": 1.5, "gain": 0.545}
K_VOICE = "pluck"   # the full pair's


def k_lead(call, alone=False, voice="lead"):
    """A second voice on K's walk, the lead guitar or the plucked string, in unison with the crunch
    synth or in its place."""
    walk = P.part(call, "bass", "K")
    if alone:
        strip(call, "bass", "K")
    if voice == "pluck":
        add(call, **dict(K_PLUCK, pat={"K": walk}))
    else:
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


def k_step(step, voice="lead"):
    """K a step at a time: 0 as it was, 1 the drums in between, 2 a second voice added to the walk
    (the lead guitar or the plucked string), 3 that voice alone on the walk."""
    def edit(call):
        if step >= 1:
            k_between(call)
        if step >= 2:
            k_lead(call, alone=step == 3, voice=voice)
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
# The seventh round's voices for the battle's new parts went with that call; what stays is each
# lift's riff on the tine piano (the map's voice for the riff in A and N) and K's walk on one voice.
# A voice's gain sets it at the phone level of U's clean guitar in U, K's walk at the harp's, but
# the sub's: a phone plays little of a sub, so the sub walks at the level it held the roots, about
# 8 dB under the harp's walk on a phone (at the harp's there it would sit 8 dB over the roots sub).
MAP_HARP = {"inst": "harp", "mode": "riff", "octave": 1, "hold": 1.5}
MAP_TINE = {"inst": "epiano", "mode": "riff", "octave": 2, "hold": 1.4}
MAP_PLUCK = {"inst": "pluck", "mode": "riff", "octave": 1, "hold": 1.5}
MAP_SUB = {"inst": "sub_bass", "mode": "riff", "legato": True}
MAP_SYNTH = {"inst": "bass", "mode": "riff", "hold": 1.0, "params": {"drive": 2.5, "cutoff": 600.0}}   # the crunch synth dark and soft, as Night Shift's map voices it
MAP_LEADS = {("C", "tine"): 0.18, ("L", "tine"): 0.18,   # (section, voice): gain
             ("K", "harp"): 0.49, ("K", "pluck"): 0.42, ("K", "sub"): 0.34, ("K", "synth"): 0.24}
MAP_VOICES = {"harp": MAP_HARP, "tine": MAP_TINE, "pluck": MAP_PLUCK, "sub": MAP_SUB, "synth": MAP_SYNTH}
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


def the_one(kw, test, what):
    """The one map voice that passes `test`."""
    found = [v for v in kw["voices"] if test(v)]
    if len(found) != 1:
        raise ValueError("%d voices are %s" % (len(found), what))
    return found[0]


def ticking(section):
    return lambda v: v["inst"] == P.TICKING["inst"] and v.get("params") == P.TICKING["params"] and section in v["pat"]


def map_k_walk(name):
    """K's walk on a single voice where the ticking guitar played it, the rest of K as it was (the
    sub on its roots, the timpani, the piano's solo over its held chords, the pads); the sub walks
    in place of holding the roots."""
    def edit(kw, call):
        del the_one(kw, ticking("K"), "the ticking guitar in K")["pat"]["K"]
        if name == "sub":
            del the_one(kw, lambda v: v["inst"] == "sub_bass" and "K" in v["pat"], "the sub in K")["pat"]["K"]
        return map_lead("K", name)(kw, call)
    return edit


def map_climax_less(name):
    """The climax's three sets a voice lighter: the ticking guitar ("ticking") or the harp ("harp"),
    which play its riff together an octave apart, out of S, R and Z."""
    test = ticking("S") if name == "ticking" else lambda v: v["inst"] == "harp" and v.get("mode", "riff") == "riff" and "S" in v["pat"]
    def edit(kw, call):
        voice = the_one(kw, test, "the %s in the climax" % name)
        for sec in "SRZ":
            del voice["pat"][sec]
        return kw
    return edit


def map_edits(*edits):
    def edit(kw, call):
        for e in edits:
            kw = e(kw, call)
        return kw
    return edit


# The climax on the ticking guitar alone (Ryan, 2 November: "keep ticking guitar but boost its
# volume"), the harp out, 3 dB up (3 November: "3db boost is fine"); the bell, the hook in R's second
# half and through Z, 3 dB down ("bring the bells down 3db, they're too loud"); the tine piano, which
# joins the guitar on the riff in Z, down ("Bring the extra riff voice down (whatever it is) in the
# final bit (Z)"): it sat 6 dB over the guitar there on a phone, so 6 dB down meets it ("bell down
# 3db, piano down 6db"). The pads held level from R into Z ("don't increase the volume of the choral
# drone in Z"): the choir joining the drone and the strings in Z put them 1 dB up on a phone.
TICKING_UP, BELLS_DOWN, Z_TINE_DOWN, Z_PADS_DOWN = 3.0, -3.0, -6.0, -1.0


def moved_off(kw, test, what, sections, db):
    """The one voice that passes `test`, its patterns for `sections` moved onto a voice of their own
    `db` dB from it, appended (every row of a set moves the same parts, so each voice keeps its
    place in the list and with it its humanising, whatever the level)."""
    voice = the_one(kw, test, what)
    kw["voices"].append(dict(voice, gain=round(voice["gain"] * 10.0 ** (db / 20.0), 4), pat={sec: voice["pat"].pop(sec) for sec in sections if sec in voice["pat"]}))


def map_climax(ticking_db=TICKING_UP, bells_db=BELLS_DOWN, tine_db=Z_TINE_DOWN, pads_db=Z_PADS_DOWN):
    """The climax's three sets without the harp, the ticking guitar alone on the riff `ticking_db`
    up, the bell `bells_db` and Z's tine piano `tine_db` from where they were, and the pads playing
    in Z (the drone, the strings, the choir) `pads_db` there; every other section as it was."""
    def edit(kw, call):
        map_climax_less("harp")(kw, call)
        moved_off(kw, ticking("S"), "the ticking guitar in the climax", "SRZ", ticking_db)
        moved_off(kw, lambda v: v["inst"] == "bell" and "Z" in v["pat"], "the bell in the climax", "RZ", bells_db)
        moved_off(kw, lambda v: v["inst"] == "epiano" and v.get("mode", "riff") == "riff" and "Z" in v["pat"], "the tine piano on Z's riff", "Z", tine_db)
        for p in kw["pad"]:
            if "Z" in p.get("sections", ""):
                p["gains"] = dict(p.get("gains", {}), Z=round(10.0 ** (pads_db / 20.0), 4))
        return kw
    return edit


# The map half as Ryan settled it: every pick, the first lift's bell calmer, both lifts' riff on the
# tine piano, the climax on the ticking guitar alone 3 dB up with the bell and Z's tine piano down
# and the drone held level into Z, K's walk on the synth bass.
map_settled = map_edits(map_picks, map_calm_bell, map_lead("C", "tine"), map_lead("L", "tine"), map_climax(), map_k_walk("synth"))


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




def battle_picks(k_voice=K_VOICE):
    """The battle half with every pick: the wrap's crash, the first lift on the crunch synth and
    the synth lead and the second on the crunch synth and the lead guitar, over the quieter backing
    guitar, M as it ships with the crunch synth, K on the drums in between with a second voice on
    the walk and its crash choked to a second and a half."""
    def edit(call):
        wrap_crash(call)
        lift("C", *CRUNCH_SYNTH)(call)
        lift("L", *CRUNCH_LEAD)(call)
        m_crunch(call)
        k_step(2, k_voice)(call)
        k_crashes()(call)
    return edit


# Hold The Line's bass on a real bass (real_bass.py; Ryan, 4 November: "Do these bass findings
# potentially change or improve anything in Hold the Line? I was never 100% satisfied with the driven
# bass"). The driven bass is the forge's plucked string tuned down through a hot amp, so its overtones
# climb over the fundamental as a note sustains (on a held E1, from 5 to 14 dB over it), a guitar's
# with gain on; and where the guitar plays power chords (A, N, B, X) a second driven bass doubles it a
# fifth above. The real bass is driven as a bassist drives an amp, its lows clean under a split and its
# mids pushed, met halfway between the driven bass's level on a phone and in full; on the roots, the
# lines a fifth above go and the guitar keeps its power chords.
REAL_DRIVEN = {"pick": 1.295, "finger": 1.419, "omnific": 1.318}
# Each voice's own bass and amp: the picked and the finger bass driven, and the Omnific kind, an
# active bass near the bridge into the modern prog drive (Ryan, 4 November: "Put the omnific-style
# active bass into Hold the Line"), met halfway with the driven bass as the others are (0.4 dB each way).
PARAMS = {"pick": {"preset": "pick", "amp": "driven"}, "finger": {"preset": "finger", "amp": "driven"},
          "omnific": {"preset": "active", "amp": "modern"},
          "modern": {"preset": "finger", "amp": "modern"}}   # the fingers into the same drive, Night Shift's bass


def semis(c):
    return int(c) if c.isdigit() else F.NOTE[c]


def fifth_above(lo, hi):
    """Whether one bass line is another a fifth higher, hit for hit: a power chord's top."""
    if not lo or len(lo) != len(hi):
        return False
    hits = 0
    for a, b in zip(lo, hi):
        if a in ".-" or b in ".-":
            if a != b:
                return False
            continue
        if semis(b) - semis(a) != 7:
            return False
        hits += 1
    return hits > 0


FIFTH_CHUG = 0.4 / 0.6   # the climax's fifth chug against its own root chug (S, R and Z)
# Every other voice that carries the bass, replaced by the real bass on its own line (Ryan, 4 November:
# "I meant replacing the existing bass voices, but without any chords where they exist"): the crunch
# synth's (the lifts' riff, M, K's walk, V) and the sub's in F, each met halfway with the voice it
# replaces between a phone and full (the crunch synth then 1.1 dB over on a phone and under in
# full, the sub, all fundamental, 4.3).
REPLACE = {"pick": {"bass": 0.863, "sub_bass": 1.062},
           "omnific": {"bass": 0.788, "sub_bass": 0.942}}   # the Omnific's: the crunch synth 1.7 dB each way, the sub 4.9
# A replaced voice heard in one section alone, met there on its own where its notes move the meeting
# point: K's walk holds every note a beat at the solo's slower tempo, and on notes that long the
# active bass falls further under the crunch synth than on its lines elsewhere, so the Omnific meets
# the walk at 0.927, 1.6 dB each way (the crunch synth's 0.788 would leave it 1.4 dB under, 0.2 over
# on a phone and 3.0 under in full).
REPLACE_IN = {"omnific": {("bass", "K"): 0.927}}
BOTH = 0.708   # two basses an octave apart, each 3 dB down so the pair holds one bass's level
CHORD_LEVEL = 1.149      # one bass playing both strings came out 1.4 dB under the two basses it replaces on a phone and 1.0 in full: this meets them halfway


def section_chug(call, s):
    """A section's own chug: its loudest palm-muted guitar an octave down."""
    gains = [v["gain"] for v in call["voices"] if v["inst"] == "guitar_real" and v.get("octave", 0) == -1
             and not v.get("params") and s in v["pat"]]
    return max(gains) if gains else 0.6


def real_bass_on(preset, roots=False, fifths=None, throughout=False, down=False, spare=(), both=False):
    """The battle's driven bass on the real bass, driven: on every part, or on the roots alone
    (`roots`), the lines a fifth above then out or moved (`fifths`): "chord", one bass playing
    each root and its fifth on two strings into one amp; "chug", the climax's fifth chug, a
    palm-muted power chord on each fifth an octave down, at the climax's balance against the
    section's own chug; "string", one guitar string on the fifth line where the bass played it.
    `throughout` replaces every other voice that carries the bass with the real bass on its own
    line (REPLACE, or REPLACE_IN for a voice heard in one section alone), but a voice heard only
    in `spare`'s sections; `down` puts every bass part an
    octave down, in the intro's register (Ryan, 4 November, of the roots row's four ways); `both`
    plays every bass part on two basses, one an octave down and one at the written root, each 3 dB
    down (BOTH)."""
    def edit(call):
        bass = [v for v in call["voices"] if v["inst"] == "bass_real"]
        added, chords = [], []
        if roots or fifths:
            pairs = [(lo, hi, s) for hi in bass for s, pat in hi["pat"].items() for lo in bass
                     if lo is not hi and fifth_above(lo["pat"].get(s, ""), pat)]
            for lo, hi, s in pairs:
                line = hi["pat"].pop(s)
                if fifths == "chord":
                    chords.append(dict(lo, pat={s: lo["pat"].pop(s)}))
                elif fifths == "chug":
                    added.append({"inst": "guitar_real", "mode": "riff", "gain": section_chug(call, s) * FIFTH_CHUG,
                                  "octave": hi.get("octave", 0) - 1, "pat": {s: line}})
                elif fifths == "string":
                    added.append({"inst": "guitar_one", "mode": "riff", "gain": section_chug(call, s) * FIFTH_CHUG,
                                  "octave": hi.get("octave", 0), "pat": {s: line}})
        replaced = []
        if throughout:
            for v in call["voices"]:
                heard = {sec for sec, pat in v["pat"].items() if any(c not in ".-" for c in pat)}
                if v["inst"] in REPLACE[preset] and heard and not heard <= set(spare):
                    own = REPLACE_IN.get(preset, {}).get((v["inst"], *heard)) if len(heard) == 1 else None
                    v.update(inst="real_bass", params=dict(PARAMS[preset]), gain=v["gain"] * (own or REPLACE[preset][v["inst"]]))
                    replaced.append(v)
        call["voices"] += chords + added
        for v in bass + chords:
            v.update(inst="real_bass", params=dict(PARAMS[preset], fifth=any(v is c for c in chords)),
                     gain=v["gain"] * REAL_DRIVEN[preset] * (CHORD_LEVEL if any(v is c for c in chords) else 1.0))
        for v in bass + chords + replaced:
            if down:
                v["octave"] = -1
            elif both:
                call["voices"].append(dict(v, pat=dict(v["pat"]), octave=-1, gain=v["gain"] * BOTH))
                v.update(octave=0, gain=v["gain"] * BOTH)
    return edit


def heard(v):
    return {s for s, p in v["pat"].items() if any(c not in ".-" for c in p)}


# The palm-muted chug: 3 dB down in A and N (Ryan, 4 November: "I think we need to bring the chug guitar
# volume down in A and N"), and only ever the rhythm (5 November: "I don't want to use the chug in unison
# lines at all (M, X, U, W, Climax, Y, V). Just only as the rhythm where it appears already"): out of M's
# line, X's riff with the bass, U's riff in octaves, W's held note, the climax's riff with the lead
# guitar and the bass and its fifth above, and the breath's root and fifth; it stays on A's, B's and
# N's power chords and as the lifts' backing on the kick. V has none: its guitar is the chord K's
# solo rings on.
CHUG_DOWN = -3.0
UNISON = "MXUWSRZYV"


def is_chug(v):
    """A palm-muted guitar an octave down (U's carries a cutoff the guitar does not read)."""
    p = v.get("params") or {}
    return v["inst"] == "guitar_real" and v.get("octave", 0) == -1 and p.get("mute", True) and not p.get("clean", False)


def chug_down(sections, db=CHUG_DOWN):
    """The palm-muted chug `db` dB down in `sections` (the lifts' backing guitars aside): a voice
    heard there alone turned down where it stands, one heard elsewhere too split (`moved_off`), so
    a set's rows split the same voices and each keeps its humanising whatever the level."""
    def edit(call):
        for v in [v for v in call["voices"] if is_chug(v) and heard(v) & set(sections)]:
            if heard(v) <= set(sections):
                v["gain"] = round(v["gain"] * 10.0 ** (db / 20.0), 4)
            else:
                moved_off(call, lambda w: w is v, "the chug", sections, db)
    return edit


def unison_chug_out(sections=UNISON):
    """The chug out of `sections`, each voice kept in its place in the list."""
    def edit(call):
        for v in call["voices"]:
            if is_chug(v):
                for sec in sections:
                    v["pat"].pop(sec, None)
    return edit


# The lifts on one bass (Ryan, 5 November: "Fingers for C and L, on the upper octave, just the single
# instrument"): each lift's riff on the fingers into the modern drive at its written octave, in the
# crunch synth's place and met halfway with it (0.979, 0.7 dB each way), the lead out (the synth lead
# in C, the lead guitar in L; 4 November: "synth lead can go").
LIFT_LEAD = {"C": "lead", "L": "guitar_real"}
LIFT_TOP = {"omnific": 0.788, "modern": 0.979}
# L's riff on a lead again, in single notes (5 November: "in L, lead guitar on the riff with single notes
# only"; "in L, the keys lead from F/Z on the riff with single notes only"): the lead guitar's clean
# voice on its one string (pair_sketches.guitar_one), or the synth lead at the octave it plays F's tune
# and Z's riff on, each met halfway with the lead guitar L had (the string 1.022, 0.0 dB each way; the
# keys 0.514, 0.2 dB: two octaves up the synth lead stood 6 dB over the guitar).
L_LEADS = {"guitar": ({"inst": "guitar_one", "params": {"mute": False, "clean": True}, "octave": 0, "hold": 0.9}, 1.022),
           "keys": ({"inst": "lead", "octave": 2, "hold": 0.9}, 0.514)}


def lift_single(preset="modern", l_lead=None):
    """Both lifts' riff on one bass on `preset` at its written octave (LIFT_TOP), each lift's lead
    out, or L's on `l_lead` (L_LEADS). Runs before `real_bass_on`, which then leaves the lifts'
    basses as they are."""
    def edit(call):
        for s, lead in LIFT_LEAD.items():
            top = the_one(call, lambda v: v["inst"] == "bass" and heard(v) == {s}, "the crunch synth in " + s)
            top.update(inst="real_bass", params=dict(PARAMS[preset]), gain=top["gain"] * LIFT_TOP[preset])
            low = the_one(call, lambda v: v["inst"] == lead and heard(v) == {s} and v.get("octave", 0) == 0, "the lead in " + s)
            if s == "L" and l_lead:
                voice, factor = L_LEADS[l_lead]
                low.pop("params", None)
                low.update({k: dict(w) if isinstance(w, dict) else w for k, w in voice.items()}, gain=round(low["gain"] * factor, 4))
            else:
                del low["pat"][s]
    return edit


def lift_double(call, sections=tuple(LIFT_LEAD)):
    """The lifts' riff in `sections` doubled an octave under its bass at its gain (Ryan, 5 November:
    "lower octave doubled by finger bass in C and L"), added last so every other voice keeps its place."""
    for s in sections:
        top = the_one(call, lambda v: v["inst"] == "real_bass" and heard(v) == {s} and v.get("octave", 0) == 0, "the lift's bass in " + s)
        call["voices"].append(dict(top, params=dict(top["params"]), pat=dict(top["pat"]), octave=-1))


def l_backing(db):
    """L's backing guitar `db` dB from where it stands (Ryan, 5 November: "backing guitar up 3db in L")."""
    def edit(call):
        v = the_one(call, lambda v: is_chug(v) and heard(v) == {"L"}, "the backing guitar in L")
        v["gain"] = round(v["gain"] * 10.0 ** (db / 20.0), 4)
    return edit


def c_backing(db):
    """C's backing guitar `db` dB from where it stands, or out (None) (5 November: "In C, backing up
    3db. 6 was too much"; "In C, backing gone entirely")."""
    def edit(call):
        v = the_one(call, lambda v: is_chug(v) and heard(v) == {"C"}, "the backing guitar in C")
        if db is None:
            del v["pat"]["C"]
        else:
            v["gain"] = round(v["gain"] * 10.0 ** (db / 20.0), 4)
    return edit


# A's back half and N, where the shipped track moves up to the driven bass's power chords on the root
# and the fifth an octave up: the low Omnific kept on the roots there and the drone 3 dB up (Ryan, 5
# November: "A and N: keep low Omnific, bring drone volume up. Scrap lower octave fifths"), and the power
# chords tried over it on other voices: the Omnific playing them (one bass, the root and its fifth on
# two strings into one amp), the lead guitar an octave over its own, the keys lead (the synth lead at
# its F octave) on the root line in single notes or in power chords an octave under, and, for his
# question ("do we have another voice option to work with here?"), the track's crunch synth in power
# chords at the guitar's octave and the brass section's an octave up. Each meets the shipped power
# chords halfway between a phone and full: within 0.4 dB each way, but the guitar's 0.2, the
# Omnific's 0.7 and the crunch synth's 1.8, its lows the heaviest.
DRONE_UP = 3.0   # the drone in A and N, in dB
TWO_AMPS = 0.485   # each of the two basses' gain where the one-amp chords' is 0.610 (0.2 dB each way)
AN_VOICES = {   # name: (voice, its intervals over the root line in semitones, each voice's gain)
    "omnific": ({"inst": "real_bass", "params": {"preset": "active", "amp": "modern", "fifth": True}, "octave": 0, "hold": 1.1}, (0,), 0.610),
    "guitar": ({"inst": "guitar_real", "params": dict(LEAD_GUITAR), "octave": 1, "hold": 0.9}, (0,), 1.374),
    "keys": ({"inst": "lead", "octave": 2, "hold": 0.9}, (0,), 0.827),
    "keys_chords": ({"inst": "lead", "octave": 1, "hold": 0.9}, (0, 7, 12), 0.563),
    "crunch": ({"inst": "bass", "params": {"drive": 3.5, "cutoff": 800.0}, "octave": 0, "hold": 1.0}, (0, 7, 12), 0.518),
    "brass": ({"inst": "brass", "octave": 1, "hold": 0.9}, (0, 7, 12), 0.661),
    "backing": ({"inst": "guitar_real", "octave": 0}, (0,), 1.199),   # the backing guitar, palm-muted as it chugs, at the Omnific chords' octave: 0.3 dB each way
    # the keys lead's power chords at its single notes' octave (Ryan, 6 November: "keys lead variation but with power chords"): 0.1 dB each way
    "keys_chords_hi": ({"inst": "lead", "octave": 2, "hold": 0.9}, (0, 7, 12), 0.415),
    # One upper note of the Omnific over the low roots in the power chords' place (Ryan, 6 November: "-low
    # roots + upper octave only -low roots + upper fifth -low roots + upper fourth -low roots + upper
    # third"), on one string at the power chords' octave: the root, its fifth, its perfect fourth, or its
    # third along the key (THIRD), each met halfway with the power chords on the dirtier drive (at their
    # gain 1.1 or 1.2 dB under them in full and 0.5 to 1.1 on a phone; now 0.3 dB each way at most).
    "octave": ({"inst": "real_bass", "params": {"preset": "active", "amp": "modern"}, "octave": 0, "hold": 1.1}, (0,), 0.698),
    "fifth": ({"inst": "real_bass", "params": {"preset": "active", "amp": "modern"}, "octave": 0, "hold": 1.1}, (7,), 0.668),
    "fourth": ({"inst": "real_bass", "params": {"preset": "active", "amp": "modern"}, "octave": 0, "hold": 1.1}, (5,), 0.675),
    "third": ({"inst": "real_bass", "params": {"preset": "active", "amp": "modern"}, "octave": 0, "hold": 1.1}, ("third",), 0.677),
    # The power chords on two basses, the root on one and the fifth on the other, each into its own amp
    # (Ryan, 6 November: "is that two instruments on different amps or one on the same amp? Can I hear
    # the difference?"): the one-amp chords drive both strings through one stage, so the two notes
    # grind against each other there; on two amps each note distorts alone. Met halfway with the
    # one-amp chords on the dirtier drive.
    "two_amps": ({"inst": "real_bass", "params": {"preset": "active", "amp": "modern"}, "octave": 0, "hold": 1.1}, (0, 7), TWO_AMPS),
}
THIRD = "third"
PHRYGIAN = (0, 1, 3, 5, 7, 8, 10)   # E Phrygian, the riff's key: its F natural over E minor's chords


def third_up(n):
    """The third over a note along E Phrygian (a note off the key a minor third)."""
    o, pc = divmod(n, 12)
    if pc not in PHRYGIAN:
        return n + 3
    k = PHRYGIAN.index(pc) + 2
    return 12 * o + PHRYGIAN[k % 7] + 12 * (k // 7)
# The Omnific a little dirtier wherever it plays (Ryan, 6 November: "is there a way to try a slightly more
# distorted version of the Omnific voice? More distortion or gain or drive or whatever, just a bit
# dirtier"): real_bass.py's DIRTY, the modern drive pushed harder with less of its clean clank, about
# half again to twice its harmonic distortion (on a sine at a note's level, 17% where the modern makes 8,
# 26 where it makes 16), met halfway with the modern drive's level (at one gain 3.5 dB over on a phone,
# 2.9 in full).
DIRTY_LEVEL = 0.695
# B and M take A's and N's voices (Ryan, 5 November: "Make sure B and M keep the new voices too, they're
# treated as part of A and N in that way"): the power chords on the bass's line there too, and B's chug
# hit at A's and N's level.
CHORD_SECTIONS = "ABMN"


def shifted(pat, k):
    """A riff pattern's notes `k` semitones up, or each a third up along the key (THIRD)."""
    return "".join(c if c in ".-" else P.spell(third_up(semis(c)) if k == THIRD else semis(c) + k) for c in pat)


def drone_up(call, db=DRONE_UP):
    """The drone `db` dB up in A and N, its pad as it was elsewhere."""
    for p in call["pad"]:
        if p["inst"] == "sweep" and "A" in p.get("sections", ""):
            up = round(10.0 ** (db / 20.0), 4)
            p["gains"] = dict(p.get("gains", {}), A=up, N=up)


def an_chords(call, name, sections=CHORD_SECTIONS):
    """`name`'s power chords on the driven bass's root line in `sections` (AN_VOICES): the line under
    its fifth where the shipped track plays power chords (A's back half, B, N), its one line where
    it has no fifth (M); read before `real_bass_on` and added after it, which would otherwise take the
    crunch synth's for a bass part of its own."""
    voice, intervals, gain = AN_VOICES[name]
    pat = {}
    for s in sections:
        bass = [v for v in call["voices"] if v["inst"] == "bass_real"]
        lows = [lo for lo in bass for hi in bass if lo is not hi and fifth_above(lo["pat"].get(s, ""), hi["pat"].get(s, ""))]
        if not lows:
            lows = [v for v in bass if s in heard(v)]
        if len(lows) > 1:
            # two lines with no fifth between them (W's held B and the G over it): the lower is the root's
            lows = [min(lows, key=lambda v: min(semis(c) for c in v["pat"][s] if c not in ".-"))]
        if len(lows) != 1:
            raise ValueError("%d root lines in %s" % (len(lows), s))
        pat[s] = lows[0]["pat"][s]
    return [dict({key: dict(w) if isinstance(w, dict) else w for key, w in voice.items()}, mode="riff", gain=gain,
                 pat={s: shifted(x, k) for s, x in pat.items()}) for k in intervals]


# Round sixteen's picks (Ryan, 5 November: "HTL: omnific power chords option, no backing guitar in C,
# backing guitar up 3db in L, keys lead on L riff").
L_BACKING_UP = 3.0


def dirtier(call):
    """Every Omnific part on the dirtier drive at the modern's level (DIRTY_LEVEL)."""
    for v in call["voices"]:
        p = v.get("params") or {}
        if v["inst"] == "real_bass" and p.get("preset") == "active" and p.get("amp") == "modern":
            v.update(params=dict(p, amp="dirty"), gain=v["gain"] * DIRTY_LEVEL)


def round16(an="omnific", double=False, dirty=False):
    """Round sixteen's battle half (Ryan, 5 November): the Omnific an octave down on the roots in
    every voice that carries the bass but the lifts' and F's punchy sub (at the Omnific set's low
    row's levels as he picked it), the lifts' riff on the fingers at its octave, the chug only as
    the rhythm and 3 dB down in A, B and N, the drone 3 dB up in A and N; his picks of round
    fifteen: the Omnific's power chords over the low roots in A's back half, B, M and N, C without
    its backing guitar, L's backing guitar 3 dB up and L's riff on the keys lead. `an` the power
    chords' voice (AN_VOICES), `double` the lifts' riff doubled an octave down on the fingers,
    `dirty` the Omnific on the dirtier drive."""
    def edit(call):
        battle_picks()(call)
        chug_down("ABN")(call)
        unison_chug_out()(call)
        drone_up(call)
        chords = an_chords(call, an) if an else []
        lift_single("modern", "keys")(call)
        real_bass_on("omnific", roots=True, throughout=True, spare=("F",), down=True)(call)
        call["voices"] += chords
        c_backing(None)(call)
        l_backing(L_BACKING_UP)(call)
        if double:
            lift_double(call)
        if dirty:
            dirtier(call)
    return edit


def round17(upper="omnific", n=None):
    """Round seventeen's battle half (Ryan, 6 November): round sixteen's with every Omnific part on
    the dirtier drive ("that's what that voice needs to sound like everywhere it's used"), the power
    chords' place over the low roots on `upper` (AN_VOICES: the power chords, or one upper note), and
    N's on `n` where it is given (the keys lead's power chords an octave under, "in N only")."""
    def edit(call):
        battle_picks()(call)
        chug_down("ABN")(call)
        unison_chug_out()(call)
        drone_up(call)
        chords = an_chords(call, upper, "ABM") + an_chords(call, n, "N") if n else an_chords(call, upper)
        lift_single("modern", "keys")(call)
        real_bass_on("omnific", roots=True, throughout=True, spare=("F",), down=True)(call)
        call["voices"] += chords
        c_backing(None)(call)
        l_backing(L_BACKING_UP)(call)
        dirtier(call)
    return edit


# Round eighteen (Ryan, 6 November: "Can I get the lower octave unison back in C and/or L again? I just
# realized how bare C sounds on headphones"): the first lift's riff doubled an octave down, the full pair's.
LIFT_DOUBLE = ("C",)


def round18(upper="omnific", n=None, double=LIFT_DOUBLE, repeat=None):
    """Round eighteen's battle half: round seventeen's (every Omnific part on the dirtier drive, the
    power chords' place over the low roots on `upper`, N's on `n` where it is given) with the lifts'
    riff doubled an octave down in `double`; `repeat` plays N twice through, `upper` the first time
    and `repeat` (AN_VOICES) the second ("What would N sound like if we played the omnific power
    through the first half, and keys lead on the repeat?"), on a form with N's bars doubled."""
    def edit(call):
        battle_picks()(call)
        chug_down("ABN")(call)
        unison_chug_out()(call)
        drone_up(call)
        if repeat:
            first, second = an_chords(call, upper, "N"), an_chords(call, repeat, "N")
            for v in first:
                v["pat"]["N"] += "." * len(v["pat"]["N"])
            for v in second:
                v["pat"]["N"] = "." * len(v["pat"]["N"]) + v["pat"]["N"]
            chords = an_chords(call, upper, "ABM") + first + second
        elif n:
            chords = an_chords(call, upper, "ABM") + an_chords(call, n, "N")
        else:
            chords = an_chords(call, upper)
        lift_single("modern", "keys")(call)
        real_bass_on("omnific", roots=True, throughout=True, spare=("F",), down=True)(call)
        call["voices"] += chords
        c_backing(None)(call)
        l_backing(L_BACKING_UP)(call)
        dirtier(call)
        if double:
            lift_double(call, double)
    return edit


# Round nineteen (Ryan, 6 November). The upper Omnific's power chords over the low roots through the half's
# middle as well ("Now that the upper bass is settled, we need it to fill out M, X, U, W, the climax, and Y"):
# M had them; X's riff, U's, the climax's (S, R, Z) and the held notes of W and Y take them, on the line
# the low Omnific plays there, the climax's line a fifth over it out as everywhere. N on the keys lead's
# power chords an octave under, twice through. The lifts' riff on the one bass again ("scrap the doubling
# in the lifts, it was better how I had it").
UPPER_SECTIONS = "ABMXUWSRZY"
# K's walk off the Omnific ("Bass in K should either be finger bass or sub from F, not sure. But not omnific
# bass"): the fingers into the modern drive, the lifts' bass, an octave down where the walk was, or F's
# punchy sub at F's octave, each met halfway with the Omnific's walk; or the crunch synth it shipped on, as
# it shipped (round twenty, 7 November: "if we could bring back the crunch synth as an option that would be
# great too").
K_BASS = "fingers"
K_FINGERS = 2.228   # 0.9 dB each way
K_SUB = 1.854       # 4.1 dB each way: a phone plays little of a sub, so it sits under the walk there and over it in full
K_BASSES = {"fingers": ({"inst": "real_bass", "params": {"preset": "finger", "amp": "modern"}}, "K_FINGERS"),
            "sub": ({"inst": "sub_bass", "params": {"res": 0.35, "punch": 2.4, "fade": 0.4}, "octave": 0, "legato": True}, "K_SUB")}
# What walks beside K's bass (7 November: "I'd like to hear it paired with the synth lead from L instead of the
# plucked string, and a version where it's up an octave"): the plucked string, or the synth lead that plays
# L's riff at the plucked string's octave or an octave over it, each met halfway with the plucked string.
K_PAIR = "pluck"
K_LEAD, K_LEAD_UP = 0.392, 0.286   # 0.6 and 0.2 dB each way
K_LEADS = {"lead": (1, K_LEAD), "lead_up": (2, K_LEAD_UP)}
# Round twenty-one (7 November: "can I hear crunch synth with the synth-lead-octave-up option? And crunch synth with
# plucked string, but the plucked string down like 3db?"): the walk on the crunch synth as it shipped, beside the
# synth lead an octave up or the plucked string 3 dB under where it was ("pluck_down").
K_PLUCK_DOWN = -3.0
K21_BASS, K21_PAIR = "crunch", "pluck_down"
# X's riff in quarter-tones (6 November: "Lowering the first high C by a quarter, and then at the second C, keep
# it at C and descend by quarters instead of semis"; 7 November: "I meant the riff for quarter tones, and
# walking down FROM C in quarters, landing on B. Not the backing chords"): the seven's two-bar riff played as
# four, the first time its high C a quarter-tone flat (B and A after it as written), the second time from C
# down in quarter-tones, C, C a quarter flat, B, landing on B where A was. Every voice on the riff takes it:
# the battle's low Omnific and the power chords over it (their fifth follows the root), the map's ticking
# guitar and tine piano. forge.py's riff reads a voice's own `notes`: a quarter-tone is half a semitone.
RIFF_NOTES = {"w": 7.5}   # C a quarter-tone flat
X_RIFF = "0-..3-..5-3-0." "0-..3-..8-7-5."
X_RIFF_Q = "0-..3-..5-3-0." "0-..3-..w-7-5." "0-..3-..5-3-0." "0-..3-..8-w-7."
# Round twenty-one (7 November: "Write out the X riff for me, it doesn't sound like what I intended. Only the
# instruments playing the riff should be using the quarter tones"): the other reading of the second pass, its
# walk squeezed in and its A kept, C and the quarter-flat C as sixteenths, then B and A as written.
X_RIFF_QA = "0-..3-..5-3-0." "0-..3-..w-7-5." "0-..3-..5-3-0." "0-..3-..8w7-5."
X_RIFFS = (X_RIFF, X_RIFF_Q, X_RIFF_QA)

# X's quarter-tones heard four ways (Ryan, 7 November, on the written-out riff: "Your read of what I wanted to
# hear was correct, as per your transcription. It's just hard to reconcile quarter tones in my head with
# actually hearing them precisely. Can I hear it with the lower and upper bass bending the roots, but the power
# fifth NOT bending? Or, with neither of the bass lines bending, but adding a guitar voice that plays the bent
# line?"): as the pair has it; the roots bending and the power chords' fifth on the unbent note's fifth, still
# one string grinding against the other in one amp (real_bass' `fifth_unbent`); or neither bass bending, the
# basses on the line with C where it bends (X_RIFF_UNBENT, the second pass C, C, B) or on the riff as
# written, under the lead guitar on the bent line an octave over the power chords (XQ_GUITAR), met halfway
# with the power chords' level.
X_RIFF_UNBENT = "0-..3-..5-3-0." "0-..3-..8-7-5." "0-..3-..5-3-0." "0-..3-..8-8-7."
XQ_GUITAR = {"inst": "lead_real", "mode": "riff", "octave": 1, "gain": 0.834}   # 0.5 dB each way: at 0.2 it sat 12 dB under the power chords on a phone, 13 in full
XQ_WAYS = ("pair", "fifth", "guitar", "guitar_written")

def x_riff(call, riff=X_RIFF_Q):
    """X's riff in quarter-tones (`riff`, X_RIFF_Q or X_RIFF_QA) on every voice that plays it."""
    riffs = [v for v in call["voices"] if v.get("pat", {}).get("X") == X_RIFF]
    if not riffs:
        raise ValueError("no voice plays X's riff as it was written")
    for v in riffs:
        v["pat"]["X"] = riff
        v["notes"] = dict(v.get("notes") or {}, **RIFF_NOTES)
    return call


def x_alone(call):
    """X with its riff's voices alone over the kit: every other voice out of X, so the riff is heard as it is played."""
    for v in call["voices"]:
        if "X" in v.get("pat", {}) and v["pat"]["X"] not in X_RIFFS:
            del v["pat"]["X"]
    return call


# W in six beats (METER): two beats of held notes fading, then four of drums (7 November: "the instruments
# need to hold a bit longer, assuming that's possible with the bass voices. If not, then we'll need to add the
# synth from F to help, like in Y ... 2 beats of fading held notes, and 4 of drum fills"). The basses cannot
# hold: a held B falls 6 to 7 dB a beat on every one of them, the string dying as a string does. So F's synth,
# the synth lead's quiet line under F's tune that holds its notes a bar and more, holds the guitar's B with
# them (W_SYNTH): at its level in F it added nothing (13 dB under them), so it comes in at their level on a
# phone and fades 6 dB over the two beats, and the held chord falls 8.7 dB across them on a phone where the
# basses alone fell 14.5. The fill is new (7 November: "Might need to rewrite the fill, it could be
# more epic anyway, Bonham triplets/quadruplets, real showy, like the last drum fill in YYZ before the guitar
# solo"): Bonham's triplets, two hands and the foot in sextuplets, on the tom then the snare; a sextuplet run
# down the kit; then half a beat of twelve to the beat down the toms and three accented sextuplets with the
# kick into the climax's crash, rising all the way from six tenths to over full.
W_STEPS, W_HELD = 72, 24   # twelve steps a beat, the held notes two beats
W_SYNTH = {"inst": "lead", "mode": "riff", "octave": 1, "gain": 1.4, "params": {"fade": 6.0}, "pat": {"W": "7" + "-" * 23 + "." * 48}}


def w_bar(events, names):
    rows = {k: ["."] * W_STEPS for k in names}
    for drum, step, vel in events:
        rows[drum][step] = vel
    return {k: "".join(v) for k, v in rows.items()}


W_FILL = w_bar(
    [("crash", 0, "x"), ("kick", 0, "x")]
    + [("tom", 24, "6"), ("tom", 26, "6"), ("kick", 28, "7"), ("tom", 30, "7"), ("tom", 32, "7"), ("kick", 34, "7")]          # Bonham's triplets
    + [("snare", 36, "7"), ("snare", 38, "7"), ("kick", 40, "8"), ("snare", 42, "8"), ("snare", 44, "8"), ("kick", 46, "8")]
    + [("snare", 48, "8"), ("kick", 48, "8"), ("snare", 50, "8"), ("tom", 52, "9"), ("tom", 54, "9"), ("kick", 54, "8"),
       ("tom2", 56, "9"), ("tom2", 58, "9")]                                                                                     # a sextuplet run down the kit
    + [("snare", 60, "9"), ("snare", 61, "9"), ("tom", 62, "9"), ("tom", 63, "x"), ("tom2", 64, "x"), ("tom2", 65, "x"),       # twelve to the beat down the toms
       ("tom2", 66, "a"), ("kick", 66, "a"), ("snare", 68, "b"), ("kick", 68, "b"), ("tom2", 70, "c"), ("kick", 70, "c")],    # and three over full into the crash
    ("kick", "snare", "tom", "tom2", "crash"))


def w_held(v):
    """A voice's W pattern on the six-beat bar: a note held two beats, or a hit on the one."""
    first = next((c for c in v["pat"]["W"] if c not in ".-"), None)
    if first is None:
        return "." * W_STEPS
    if v.get("mode", "riff") == "riff":
        return first + "-" * (W_HELD - 1) + "." * (W_STEPS - W_HELD)
    return first + "." * (W_STEPS - 1)



def x_way(way):
    """X's quarter-tones one of XQ_WAYS (round twenty-one's battle half otherwise)."""
    if way == "pair":
        return round21()
    if way == "fifth":
        base = round21()

        def edit(call):
            base(call)
            for v in call["voices"]:
                if v.get("pat", {}).get("X") == X_RIFF_Q and v.get("params", {}).get("fifth"):
                    v["params"] = dict(v["params"], fifth_unbent=True)
        return edit
    base = round21(riff=X_RIFF_UNBENT if way == "guitar" else None)

    def edit(call):
        base(call)
        call["voices"].append(dict(XQ_GUITAR, notes=dict(RIFF_NOTES), pat={"X": X_RIFF_Q}))
    return edit

# W's fill again (Ryan, 7 November, of round twenty's: "the 'basses alone' option actually sounds fine now with
# the 6 beats. Hilariously, your drum solo is TOO intense now, it goes at speeds that sounds unrealistic. The
# implementation of the new triplets are superb, but the speeds that you start the fill at, those should be what
# it ends at. Mostly just because a double-kick quadruplet sounds just like noise on the phone speaker ... Build to
# the triplets"): the held notes on the basses alone, and a fill that builds to Bonham's triplets and ends on
# them, nothing faster than six to the beat, the kick never more than two to the beat: eighth-note triplets on
# the snare, sixteenths down the toms, then the triplets on the tom and the snare into the climax's crash
# (W_FILL_BUILD); or the sixteenth-note descending doubles he named the same day ("as in the famous Phil
# Collins In the Air Tonight fill") down four toms into the same triplets (W_FILL_DOUBLES). The doubles want
# a tom over the kit's two and one under them (W_TOMS), built from a seed of their own so nothing else moves.
W_TOMS = {"tom_hi": 175.0, "tom_lo": 73.0}
W_FILL_BUILD = w_bar(
    [("crash", 0, "x"), ("kick", 0, "x")]
    + [("snare", 24, "5"), ("snare", 28, "5"), ("snare", 32, "6")]                    # eighth-note triplets
    + [("tom", 36, "6"), ("tom", 39, "6"), ("tom2", 42, "7"), ("tom2", 45, "7")]       # sixteenths down the toms
    + P.bonham_triplets(48, 2, ("tom", "snare"), soft="7", hard="x"),                  # Bonham's triplets into the climax
    ("kick", "snare", "tom", "tom2", "crash"))
W_FILL_DOUBLES = w_bar(
    [("crash", 0, "x"), ("kick", 0, "x")]
    + P.descending_doubles(24, ("tom_hi", "tom", "tom2", "tom_lo"), soft="6", hard="8")
    + P.bonham_triplets(48, 2, ("tom", "snare"), soft="8", hard="x"),
    ("kick", "snare", "tom", "tom2", "tom_hi", "tom_lo", "crash"))
W_FILLS = {"build": W_FILL_BUILD, "doubles": W_FILL_DOUBLES, "round20": W_FILL}
W21_FILL = "build"


def w_toms(call):
    """The doubles' two more toms in the kit, at the kit's toms' gain, from their own seed."""
    gain = call["kit"]["tom"][1]
    saved = F.RNG
    F.RNG = np.random.default_rng(zlib.crc32(b"hold_the_line_w_toms"))
    try:
        for name, f in W_TOMS.items():
            call["kit"][name] = (F.variants(lambda p, f=f: F.tom_real(f, p)), gain)
    finally:
        F.RNG = saved


def w_six(call, synth=True, fill=None):
    """The battle's W on its six-beat bar: every voice's note held two beats, F's synth holding with them
    where `synth`, `fill` (W_FILL, round twenty's, unless given) for the drums."""
    fill = fill or W_FILL
    for v in call["voices"]:
        if "W" in v.get("pat", {}):
            v["pat"]["W"] = w_held(v)
    for name, d in call["drums"].items():
        d.pop("W", None)
    if any(name in W_TOMS for name in fill):
        w_toms(call)
    for name, pat in fill.items():
        call["drums"].setdefault(name, {})["W"] = pat
    if synth:
        call["voices"].append(dict(W_SYNTH, params=dict(W_SYNTH["params"]), pat=dict(W_SYNTH["pat"])))
    return call


def k_walk(call, which, shipped=None):
    """K's walk on `which` (K_BASSES, or "crunch", the crunch synth as it `shipped`) in place of the Omnific."""
    v = the_one(call, lambda v: v["inst"] == "real_bass" and heard(v) == {"K"}, "K's walk")
    if which == "crunch":
        v.clear()
        v.update({k: dict(w) if isinstance(w, dict) else w for k, w in shipped.items()})
        return
    voice, factor = K_BASSES[which]
    v.update({k: dict(w) if isinstance(w, dict) else w for k, w in voice.items()}, gain=round(v["gain"] * globals()[factor], 4))


def k_pair(call, which=K_PAIR):
    """What walks beside K's bass: the plucked string as it is or 3 dB down, or the synth lead from L (K_LEADS)."""
    if which == "pluck":
        return
    v = the_one(call, lambda v: v["inst"] == "pluck" and heard(v) == {"K"}, "K's plucked string")
    if which == "pluck_down":
        v["gain"] = round(v["gain"] * 10.0 ** (K_PLUCK_DOWN / 20.0), 4)
        return
    octave, factor = K_LEADS[which]
    v.update(inst="lead", octave=octave, hold=0.9, gain=round(v["gain"] * factor, 4))


def round20(upper=UPPER_SECTIONS, k_bass=K_BASS, pair=K_PAIR, quarters=True, w_synth=True, riff=X_RIFF_Q, fill=None):
    """Round twenty's battle half: round nineteen's (the upper Omnific's power chords in `upper`'s
    sections, N twice on the keys lead, the lifts on one bass) with X's riff in quarter-tones where
    `quarters`, W on its six-beat bar (F's synth holding where `w_synth`), K's walk on `k_bass` with
    `pair` beside it."""
    def edit(call):
        shipped = {k: (dict(w) if isinstance(w, dict) else w) for k, w in
                   the_one(call, lambda v: v["inst"] == "bass" and heard(v) == {"K"}, "K's walk as it ships").items()}
        battle_picks()(call)
        chug_down("ABN")(call)
        unison_chug_out()(call)
        drone_up(call)
        chords = an_chords(call, "omnific", upper) + an_chords(call, "keys_chords", "N")
        lift_single("modern", "keys")(call)
        real_bass_on("omnific", roots=True, throughout=True, spare=("F",), down=True)(call)
        call["voices"] += chords
        c_backing(None)(call)
        l_backing(L_BACKING_UP)(call)
        dirtier(call)
        k_walk(call, k_bass, shipped)
        k_pair(call, pair)
        if quarters:
            x_riff(call, riff)
        w_six(call, w_synth, fill)
    return edit



def round21(k_bass=K21_BASS, pair=K21_PAIR, fill=W21_FILL, riff=X_RIFF_Q, alone=False):
    """Round twenty-one's battle half: round twenty's with K's walk on `k_bass` beside `pair` (the crunch
    synth and the plucked string 3 dB down, the full pair's), W's held notes on the basses alone and its
    fill `fill` (W_FILLS), X's riff `riff` (as written where None), alone over the kit where `alone`."""
    base = round20(k_bass=k_bass, pair=pair, quarters=riff is not None, w_synth=False, riff=riff or X_RIFF_Q, fill=W_FILLS[fill])

    def edit(call):
        base(call)
        if alone:
            x_alone(call)
    return edit

# The map half's rounds nineteen and twenty (Ryan, 6 and 7 November): L's riff and M's line on a clean finger
# bass in place of the cellos ("Change L and M from cellos (i think?) to finger bass"), met halfway with them,
# the map's no-gain rule kept (a direct box, no amp); U's sub walking the riff as the climax's sub walks its
# roots ("Can we get the bass from the start of the climax to show up in U?"; then "Map U is what I meant,
# yeah, you got it right in the full pair"); X's riff in quarter-tones with the battle's; the tine piano that
# plays L's riff on M's line as well ("Map M, can the upper voice from L join in too?"); W on its six-beat
# bar, the low strings held through it, the sub and the tine two beats, the timpani's roll over the last four.
LM_FINGERS = {"inst": "real_bass", "params": {"preset": "finger", "amp": "di"}, "mode": "riff", "octave": 0, "hold": 1.1}
LM_FACTOR = 1.055   # 0.3 dB each way
U_BASS = "sub"
MAP_W_ROLL = w_bar([("timp_W7", step, vel) for step, vel in
                    ((24, "4"), (36, "4"), (42, "5"), (48, "5"), (51, "5"), (54, "6"), (57, "6"), (60, "7"), (62, "7"),
                     (64, "7"), (66, "8"), (67, "8"), (68, "9"), (69, "9"), (70, "x"), (71, "x"))], ("timp_W7",))["timp_W7"]


def map_x_riff(kw, call):
    return x_riff(kw)


def map_lm_fingers(kw, call):
    cello = the_one(kw, lambda v: v["inst"] == "cello_real" and {"L", "M"} <= heard(v), "the cellos in L and M")
    kw["voices"].append(dict(LM_FINGERS, params=dict(LM_FINGERS["params"]), gain=round(cello["gain"] * LM_FACTOR, 4),
                             pat={sec: cello["pat"].pop(sec) for sec in "LM"}))
    return kw


def map_u_bass(how=U_BASS):
    def edit(kw, call):
        ticking = the_one(kw, lambda v: v["inst"] == "guitar_real" and "U" in heard(v) and v.get("octave", 0) == 0, "the ticking guitar in U")
        if how == "sub":
            sub = the_one(kw, lambda v: v["inst"] == "sub_bass" and "U" in heard(v), "the sub in U")
            kw["voices"].append({"inst": "sub_bass", "mode": "riff", "gain": sub["gain"], "octave": 0, "hold": 0.9, "pat": {"U": ticking["pat"]["U"]}})
            del sub["pat"]["U"]
        elif how == "ticking":
            moved_off(kw, lambda v: v is ticking, "the ticking guitar in U", ("U",), TICKING_UP)
        return kw
    return edit


def map_m_tine(kw, call):
    tine = the_one(kw, lambda v: v["inst"] == "epiano" and v.get("octave", 0) == 2 and heard(v) == {"L"}, "the tine piano in L")
    line = the_one(kw, lambda v: v["inst"] == "real_bass" and "M" in heard(v), "M's line on the finger bass")
    tine["pat"]["M"] = line["pat"]["M"]
    return kw


def map_w_six(kw, call):
    for v in kw["voices"]:
        if "W" not in v.get("pat", {}):
            continue
        if v["inst"] in ("cello_real", "contrabass_real"):
            first = next(c for c in v["pat"]["W"] if c not in ".-")
            v["pat"]["W"] = first + "-" * (W_STEPS - 1)              # the low strings held through
        elif v["inst"] == "swell_rev":
            v["pat"]["W"] = "." * (W_STEPS - 6) + "x" + "." * 5      # its peak on the climax's one, as before
        else:
            v["pat"]["W"] = w_held(v)
    for name, d in kw["drums"].items():
        if "W" in d:
            d["W"] = MAP_W_ROLL if name == "timp_W7" else "." * W_STEPS
    return kw


map_settled20 = map_edits(map_picks, map_calm_bell, map_lead("C", "tine"), map_lead("L", "tine"), map_climax(), map_k_walk("synth"),
                          map_x_riff, map_lm_fingers, map_u_bass(), map_m_tine, map_w_six)


def battle_with(*edits):
    def edit(call):
        for e in edits:
            e(call)
    return edit


FORM_TOP = FORM_K[:FORM_K.index("M") + 1]   # the half's top: the riff, both lifts and the bar down into the seven
FORM_X = "M XXXXXXXXXXXX"          # the bar down into the seven and the seven
FORM_KEYS = "Y KKKKKKKK V"         # the breath, the keys section, the second breath
FORM_W = "FFFF W SSSSSSSS"         # the keys' tune's first bars, the turn, the climax's first set
SETS = [
    {"id": "hq", "half": "battle", "title": "X's quarter-tones, four ways", "form": FORM_X,
     "note": "The bar down into the seven and the seven, the riff as you meant it (Ryan, 7 November: \"Can I hear it with the lower and upper bass bending the roots, but the power fifth NOT bending? Or, with neither of the bass lines bending, but adding a guitar voice that plays the bent line?\"). The piano, the chime and the held line play as before, in semitones. Switch rows anywhere: each carries on from the same beat.", "rows": [
        ("hq0", "Both basses bend, the fifth with them", "As the pair has it: the low Omnific and the power chords' roots bend, each fifth with its root.", x_way("pair")),
        ("hq1", "The roots bend, the fifth stays", "Both basses bend their roots; each power chord's fifth stays on the unbent note's fifth, so a bent C carries a G in tune, the two strings grinding in the one amp.", x_way("fifth")),
        ("hq2", "A guitar bends over the basses' line", "Neither bass bends: they play the line with C where it bends (the second pass C, C, B). The lead guitar plays the bent line an octave over the power chords, at their level.", x_way("guitar")),
        ("hq3", "A guitar bends over the riff as written", "Neither bass bends: they play the riff as written (the second pass C, B, A). The lead guitar plays the bent line over it.", x_way("guitar_written")),
    ]},
    {"id": "hk", "half": "battle", "title": "K on the crunch synth", "form": FORM_KEYS,
     "note": "The breath, the keys section at its slower tempo and the second breath, the walk on the crunch synth as it shipped (Ryan, 7 November: \"can I hear crunch synth with the synth-lead-octave-up option? And crunch synth with plucked string, but the plucked string down like 3db?\"). Switch rows anywhere: each carries on from the same beat.", "rows": [
        ("hk0", "The plucked string 3 dB down", "Beside the crunch synth (the full pair's).", round21()),
        ("hk1", "The synth lead an octave up", "The synth lead that plays L's riff, an octave over the plucked string's octave.", round21(pair="lead_up")),
        ("hk2", "The plucked string as it was", "Round twenty's level.", round21(pair="pluck")),
    ]},
    {"id": "hw", "half": "battle", "title": "W's fill, built to the triplets", "form": FORM_W,
     "note": "The keys' tune's first bars, W and the climax's first set, the held notes on the basses alone, your pick (Ryan, 7 November: \"the speeds that you start the fill at, those should be what it ends at ... Build to the triplets\"). Nothing faster than six to the beat, the kick at most two to the beat. Switch rows anywhere: each carries on from the same beat.", "rows": [
        ("hw0", "Building to the triplets", "Eighth-note triplets on the snare, sixteenths down the toms, then Bonham's triplets on the tom and the snare into the climax (the full pair's).", round21()),
        ("hw1", "The descending doubles into the triplets", "Two beats of sixteenth-note doubles down four toms, In the Air Tonight's fill, then the same triplets.", round21(fill="doubles")),
        ("hw2", "Round twenty's fill", "The triplets first and twelve to the beat at the end, for the comparison.", round21(fill="round20")),
    ]},
]
PAIR = {"id": "hold_the_line_r21", "title": "Hold The Line, round twenty-one"}
# The battle half's sections as round twenty plays them, where they differ from the shipped track's:
# the Omnific, wherever it plays, on the dirtier drive.
NAMES_R20 = {
    "A": "riff, sixteen bars: four bare, four with a low bass, eight with the bass low on the roots and the Omnific's power chords over it, the last four over the drone, 3 dB up; the chug 3 dB down; the Omnific dirtier, as everywhere it plays",
    "B": "turn bar: one short hit with the power chord on the bass and the Omnific's, the drums filling",
    "C": "lift: the fingers bass alone on the riff, piano stabs, metal chime, brass, syncopated snare, choir, a tom fill closing it",
    "N": "the riff again, twice through: the chug's power chords and the keys lead's an octave under over the drone, 3 dB up, the bass low on the roots, the chug 3 dB down",
    "L": "second lift: the keys lead on the riff over the fingers bass, the backing guitar on the kick 3 dB up, piano stabs",
    "M": "a bar down into the seven on the bass, the Omnific's power chords over it",
    "W": "the keys' turn, six beats: two of the tune's note held on the lead guitar, the basses and F's synth, fading; four of a showy fill, Bonham's triplets on the tom and the snare, a run down the kit, twelve to the beat on the toms into the climax",
    "R": "the climax's second set: the backing guitar joins, ringing the chord a whole bar from each one, the keys join the riff, the Omnific's power chords over the bass, the drums more intense",
    "Z": "the climax's third set: double kicks on the sixteenths, the keys on simple chords on the beat, the Omnific's power chords over the bass, nothing backed off",
    "X": "the seven: a riff for 7/8 on the bass with the Omnific's power chords over it, its high C a quarter-tone flat the first time and walking down to B in quarter-tones the second, the piano on the long beat, a chime, the lead guitar held through its second half",
    "U": "unison riff: bass and lead in octaves, the Omnific's power chords between them, a drum solo behind them in threes and twos, the drums up",
    "S": "the climax: a new unison riff on the lead guitar voice and the bass, the Omnific's power chords over the bass, the drone under it, intense drums",
    "Y": "a breath, one bar: the climax's blend held on one E minor chord (the lead guitar voice on the third, the bass on the root with the Omnific's power chord over it, the backing guitar's chord, the piano on the fifth), a swell into the drop",
    "K": "the keyboard solo's first eight bars at its slower tempo, its walk on the fingers bass an octave down with the plucked string beside it, K's drums with a pushing kick, eighths on the hat and a china, its crash choked to a second and a half",
    "V": "the second breath, one bar at the solo's tempo: the keyboard solo's instruments ring on E minor (the bass on the root, piano on the fifth, the guitar and piano chords), a swell into the fill",
}

# The battle half's sections as round twenty-one plays them, where they differ from round twenty's.
NAMES_R21 = dict(NAMES_R20,
                 W="the keys' turn, six beats: two of the tune's note held on the lead guitar and the basses, fading; four of a fill building to Bonham's triplets: eighth-note triplets on the snare, sixteenths down the toms, then the triplets on the tom and the snare into the climax",
                 K="the keyboard solo's first eight bars at its slower tempo, its walk on the crunch synth with the plucked string beside it 3 dB down, K's drums with a pushing kick, eighths on the hat and a china, its crash choked to a second and a half")

def level(x, db):
    return F.limit(F.write_level(x, NAME, db))


def render_row(job):
    """One row of a set, in a worker, from its set's seed; read as the track reads its sections."""
    si, ri = job
    F.seed("hold21_" + SETS[si]["id"])
    row = SETS[si]["rows"][ri]
    edit, form = row[3], row[4] if len(row) > 4 else SETS[si]["form"]   # a row may cut its own bars (K's lengths)
    with P.Patched(_steps=run_steps):
        if SETS[si]["half"] == "battle":
            call = copied(call_on(form, METER))
            edit(call)
            return si, ri, unmastered(call)
        return si, ri, unmastered(map_call(form, edit))


def full_path(half):
    return os.path.join(P.OUT, "hold21_full_%s.wav" % half)


def render_full(half):
    """One full half, in a worker, from the shipped half's seed, at its half's level."""
    if half == "battle":
        F.seed(NAME)
        call = copied(call_on(FORM_K, METER))
        round21()(call)
        x = level(F.groove(**call), BATTLE_LEVEL)
    else:
        F.seed(NAME + "_map")
        x = level(map_half(FORM_K, map_settled20), MAP_LEVEL)
    P.write(os.path.basename(full_path(half))[:-4], x, aac=False)
    return half


def bars_of(form, meter, bpm):
    form = form.replace(" ", "")
    steps, _, scales = F._bars(form, meter)
    return form, np.concatenate([[0.0], np.cumsum([s * k * 15.0 / bpm for s, k in zip(steps, scales)])])


def sections_of(form, meter, bpm, names_over=None):
    form, at = bars_of(form, meter, bpm)
    names = dict(F.MUSIC[NAME]["names"], **(names_over or {}))
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
    manifest_path = os.path.join(P.OUT, "hold21.json")
    manifest = json.load(open(manifest_path)) if os.path.exists(manifest_path) else {"sets": [], "tracks": [], "seams": []}
    for si, s in enumerate(SETS):
        if s["id"] not in wanted:
            continue
        # One master and one gain for the set, the gain the one that brings its first row to its
        # half's level, so the rows differ only by what changed.
        mastered = master_together([raw[si, ri] for ri in range(len(s["rows"]))])
        gain = 10.0 ** (((BATTLE_LEVEL if s["half"] == "battle" else MAP_LEVEL) - F.mean_level(mastered[0])) / 20.0)
        rows = []
        for ri, (rid, title, note, *_edit) in enumerate(s["rows"]):
            x = F.limit(mastered[ri] * gain)
            rows.append({"id": rid, "title": title, "note": note, "file": os.path.basename(P.write("hold21_" + rid, x)),
                         "seconds": round(len(x) / F.SR, 2), "phone_db": P.measure(rid, x)["phone_db"]})
        manifest["sets"] = [e for e in manifest["sets"] if e["id"] != s["id"]] + [{"id": s["id"], "half": s["half"], "title": s["title"], "note": s["note"], "rows": rows}]
        print("%-2s %s" % (s["id"], "  ".join("%s %.1f" % (r["id"], r["phone_db"]) for r in rows)))
    manifest["sets"] = [e for e in manifest["sets"] if e["id"] in [s["id"] for s in SETS]]   # a set retired from SETS leaves the page
    manifest["sets"].sort(key=lambda e: [s["id"] for s in SETS].index(e["id"]))
    manifest["seams"] = []
    if "full" in wanted:
        bpm = F.MUSIC[NAME]["bpm"]
        m, b = (P.read_wav(full_path(h)) for h in ("map", "battle"))
        if len(m) != len(b):
            raise ValueError("the halves are %d and %d samples" % (len(m), len(b)))
        P.write(PAIR["id"] + "_pair", [m, b], kbps=384)
        secs, total, at = sections_of(FORM_K, METER, bpm, NAMES_R21)
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

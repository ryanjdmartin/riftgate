"""Hold The Line's thirteenth round as a pair (Ryan, 3 November, on the twelfth round's page): the
track settled ("I think that's it for this track").

  the climax     "bell down 3db, piano down 6db, and don't increase the volume of the choral drone
                 in Z": the ticking guitar alone on the riff 3 dB up through S, R and Z, the bell on
                 its hook 3 dB down, the tine piano on Z's riff 6 dB down; and the drone held level
                 from R into Z. In R the drone and the strings hold under the riff; in Z the choir
                 joins them, which put the pads 1 dB up on a phone, so the drone, the strings and
                 the choir sit 1 dB down through Z and the choir's colour arrives without the drone
                 growing. A set puts it beside the twelfth round's pair.
  K              "The 8 bars is perfect": K's first eight bars in both halves, closing on E's
                 tritone chord (E with B flat and F), which the breath's E5 resolves.

Kept from the earlier rounds: the battle half as the seventh round has it (the loop without J, V
and Q kept, Q's fill landing on the wrap at bar nine with a crash; the first lift on the crunch
synth and the synth lead and the second on the crunch synth and the lead guitar over the backing
guitar 6 dB down, a crash every four bars; M as it ships with the crunch synth; K at its slower
tempo on the drums in between with its long crash choked to a second and a half, the plucked
string beside the crunch synth on its walk 3 dB down); his map picks (X's held walk on the violins,
U's lead on the clean guitar, the climax's drone moved from S to R, W on the low note with the
roll; the first lift's bell once a bar and both lifts' riff on the tine piano; K's walk on the
synth bass; the climax without the harp). The map halves are minimal (Ryan, 30 October: "in
general the map tracks need to be minimalist").

The full pair on the switch takes every pick. The set is an excerpt for A/B, its rows the same
bars from the same seed through one master at one gain.

    tools/spriter/.venv/bin/python tools/soundforge/hold_sketches.py          # the set and the pair, then hold13.json beside the pairs (about five minutes on four cores)
    tools/spriter/.venv/bin/python tools/soundforge/hold_sketches.py mz       # the named sets only (mz, and full for the pair)
"""
import json
import os
import sys
from concurrent.futures import ProcessPoolExecutor

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import real_bass  # noqa: E402,F401  (the real basses' voice)
import pair_sketches as P  # noqa: E402

NAME = "music_hold_the_line"
SHIPPED_FORM = F.MUSIC[NAME]["form"]
METER = dict(F.MUSIC[NAME]["meter"])            # the seven in 7/8, K and V at the solo's slower tempo (Ryan, 30 October: "keep the tempo drop")
FORM_K16 = SHIPPED_FORM.replace(" JJ", "")       # the loop without J: Q's fill into the wrap
K_BARS = 8   # K's first eight bars (Ryan, 30 October: "the first 14 bars"; 2 November: "chop 4 more bars off the end of K", then "add one more bar back"; 3 November, of eleven, twelve and eight: "The 8 bars is perfect")


def k_form(bars=K_BARS):
    """The loop without J, K cut to its first `bars` bars."""
    return FORM_K16.replace("K" * 16, "K" * bars)


FORM_K = k_form()
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


CLIMAX = "WW SSSSSSSS RRRRRRRR ZZZZZZZZ Y"


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
          "omnific": {"preset": "active", "amp": "modern"}}


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


def battle_with(*edits):
    def edit(call):
        for e in edits:
            e(call)
    return edit


CLIMAX_EDIT = (map_picks, map_calm_bell)
SETS = [
    {"id": "mz", "half": "map", "title": "The map's climax, the drone into Z", "form": CLIMAX,
     "note": "The keys' turn, the climax's three sets (S, R and Z) and the breath: the ticking guitar alone on the riff 3 dB up over the sub, the drone and the strings joining in R with the bell on the hook in its second half, the bell 3 dB down, the choir and the tine piano 6 dB down on the riff in Z.", "rows": [
        ("mz0", "As the twelfth round's pair had it", "The choir joining the drone and the strings in Z, the pads 1 dB up there on a phone.", map_edits(*CLIMAX_EDIT, map_climax(pads_db=0.0))),
        ("mz1", "The drone held level into Z", "The drone, the strings and the choir 1 dB down through Z, so the choir arrives without the drone growing (the full pair's).", map_edits(*CLIMAX_EDIT, map_climax())),
    ]},
    {"id": "hb", "half": "battle", "title": "The bass, through the whole battle half", "form": FORM_K,
     "note": "The settled battle half from the top, the bass on each voice wherever it plays: the riff, the turn's walk, the climax. Each real bass is built as a bass and driven as a bassist drives an amp, its lows clean and its mids pushed, met halfway between the driven bass's level on a phone and in headphones. Switch rows anywhere: each carries on from the same beat.", "rows": [
        ("hb0", "The driven bass as it ships", "The settled pair's: the forge's guitar string tuned down through a hot amp, a second driven bass a fifth above wherever the guitar plays power chords.", battle_picks()),
        ("hb1", "A real bass, picked and driven", "The same parts, the fifths above included, on a picked bass through a driven amp.", battle_with(battle_picks(), real_bass_on("pick"))),
        ("hb2", "Picked and driven, on the roots", "The lines a fifth above out, so the bass holds the roots under the guitar's power chords.", battle_with(battle_picks(), real_bass_on("pick", roots=True))),
        ("hb3", "Fingers, driven, on the roots", "Fingers in place of the pick, rounder at the front, through the same amp, on the roots.", battle_with(battle_picks(), real_bass_on("finger", roots=True))),
    ]},
    {"id": "hv", "half": "battle", "title": "The bass on the roots, four ways", "form": FORM_K,
     "note": "The settled battle half from the top on the picked, driven real bass, each row one change from the roots alone (Ryan, 4 November). Switch rows anywhere: each carries on from the same beat.", "rows": [
        ("hv0", "Picked and driven, on the roots", "As the bass set's third row has it: the lines a fifth above out.", battle_with(battle_picks(), real_bass_on("pick", roots=True))),
        ("hv1", "On the roots throughout", "Every voice that carries the bass on the real bass: the driven bass's parts on their roots, and the crunch synth's (the lifts' riff, M, K's walk, V) and the sub's in F on their own lines, each met halfway with the voice it replaces.", battle_with(battle_picks(), real_bass_on("pick", roots=True, throughout=True))),
        ("hv2", "A second bass on the fifths", "The fifths on a second bass beside the first, each through its own amp: the bass set's second row, and how the driven bass always played them.", battle_with(battle_picks(), real_bass_on("pick"))),
        ("hv3", "One bass playing both strings", "Each root and its fifth plucked together on one bass into one amp, so the drive grinds them into each other, met halfway with the two basses' level.", battle_with(battle_picks(), real_bass_on("pick", fifths="chord"))),
        ("hv4", "The climax's guitar on the fifths", "The fifths taken over by the guitar that plays them at the climax: a palm-muted power chord on each, an octave down, at the climax's balance against the section's own chug.", battle_with(battle_picks(), real_bass_on("pick", fifths="chug"))),
        ("hv5", "One guitar string on the fifths", "The fifth line alone on one string of that guitar, where the second bass played it.", battle_with(battle_picks(), real_bass_on("pick", fifths="string"))),
        ("hv6", "On the roots an octave down", "Every bass part in the intro's low register throughout, at the chug's root.", battle_with(battle_picks(), real_bass_on("pick", roots=True, down=True))),
    ]},
    {"id": "ho", "half": "battle", "title": "The Omnific bass, through the whole battle half", "form": FORM_K,
     "note": "The settled battle half from the top, every voice that carries the bass on an active bass played near the bridge into a modern prog drive, the crunch synth with it (K's walk included), but F's punchy sub, its signature (Ryan, 4 November: \"I meant F keeps it's old sub bass\"). Each meets the voice it replaces halfway between a phone and headphones. Switch rows anywhere: each carries on from the same beat.", "rows": [
        ("ho0", "On the roots, as written", "Single notes on the roots at their written octaves.", battle_with(battle_picks(), real_bass_on("omnific", roots=True, throughout=True, spare=("F",)))),
        ("ho1", "On the roots, the low octave", "The same an octave down throughout, the intro's register.", battle_with(battle_picks(), real_bass_on("omnific", roots=True, throughout=True, spare=("F",), down=True))),
        ("ho2", "A second bass on the fifths", "The roots, and a second bass on the fifths where the guitar plays power chords, each through its own amp.", battle_with(battle_picks(), real_bass_on("omnific", throughout=True, spare=("F",)))),
        ("ho3", "Two basses, the low octave and the root", "Every root on two basses an octave apart, each 3 dB down so the pair holds one bass's level.", battle_with(battle_picks(), real_bass_on("omnific", roots=True, throughout=True, spare=("F",), both=True))),
    ]},
]
PAIR = {"id": "hold_the_line_r13", "title": "Hold The Line, round thirteen",
        "k": "the keyboard solo's first eight bars at its slower tempo, the crunch synth and the plucked string 3 dB down on the walk, K's drums with a pushing kick, eighths on the hat and a china, its crash choked to a second and a half"}


def level(x, db):
    return F.limit(F.write_level(x, NAME, db))


def render_row(job):
    """One row of a set, in a worker, from its set's seed; read as the track reads its sections."""
    si, ri = job
    F.seed("hold13_" + SETS[si]["id"])
    row = SETS[si]["rows"][ri]
    edit, form = row[3], row[4] if len(row) > 4 else SETS[si]["form"]   # a row may cut its own bars (K's lengths)
    with P.Patched(_steps=run_steps):
        if SETS[si]["half"] == "battle":
            call = copied(call_on(form, METER))
            edit(call)
            return si, ri, unmastered(call)
        return si, ri, unmastered(map_call(form, edit))


def full_path(half):
    return os.path.join(P.OUT, "hold13_full_%s.wav" % half)


def render_full(half):
    """One full half, in a worker, from the shipped half's seed, at its half's level."""
    if half == "battle":
        F.seed(NAME)
        call = copied(call_on(FORM_K, METER))
        battle_picks()(call)
        x = level(F.groove(**call), BATTLE_LEVEL)
    else:
        F.seed(NAME + "_map")
        x = level(map_half(FORM_K, map_settled), MAP_LEVEL)
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
    manifest_path = os.path.join(P.OUT, "hold13.json")
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
            rows.append({"id": rid, "title": title, "note": note, "file": os.path.basename(P.write("hold13_" + rid, x)),
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
        secs, total, at = sections_of(FORM_K, METER, bpm, PAIR["k"])
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

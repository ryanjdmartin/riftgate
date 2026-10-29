"""Every track as a pair (Ryan, 24 and 28 October; the bible's pair row): a track written once and
voiced twice on one timeline, a map half and a battle half, so the screen changing changes what
plays, never where the music is (FTL's sectors). The map half is re-voiced, not turned down: the
drums cut, the instruments swapped for less gain, a strategic sound rather than combat; the
battle half is the fight, and since a fight joins the track wherever the map has it, it holds
its intensity (the calm lives in the map half).

Each track has one half shipped (art/audio/music_<track>.wav) and one written here, on the
shipped recipe's own groove call: captured rather than copied, so the new half shares the form,
tempo, metres, chords and every note the recipe writes, sample for sample, and an edit to the
recipe moves both halves. Hold The Line's map half came first (24 October, "almost exactly what
I pictured" on 28 October: the ticking guitar great, the bells a little loud). Its rules carry to
every map half:

  the kit      gone: no kick, snare, hats, cymbals, toms or timpani.
  the gain     a chugged figure goes to the mechanical guitar, clean and muted (Night Shift's
               rhythm guitar, an octave over the chug): the ticking; a driven bass to the soft sub
               on the riff, or held on the root where the battle drives.
  the voices   the map's own: the tine piano, the harp, spiccato cellos, a soft horn, the bell
               for the fight's metal chime (3 dB under Hold The Line's first cut), bowed strings
               where guitars ring; no brass stabs, no orchestral hits.
  the bed      the saw drone under a human track's riffs, a swept pad or the choir elsewhere,
               the pump eased, a backwards swell where the battle fills, no crescendo.
  the level    the map's (Night Shift's and Low Ground's).

And to every battle half: the fight's kit (the kick still keeping its place in each section),
the chugged guitar and the driven bass on the track's own figures, the drone under a human
track, brass and timpani in a rift track, at the fight's level.

Writes into tools/soundforge/out/pairs/: each new half (<track>_map.wav or <track>_battle.wav);
each pair as one stereo file (<track>_pair.mp4, the map left and the battle right, each channel
coded on its own, with no joint or intensity stereo, so neither leaks into the other) for the
page's live switch; and Hold The Line's run as the game would play it: the battle opening on
the map, an engage, the map crossfading into the fight over three seconds from it, a victory and
back to the field, then a hunter's contact whose fight lands in the keys section, every effect
at its shipped level under the game's dips (Sound.DIP). The page is pair_page.html, copied in as
index.html: publish it with manifest.json, the pairs and the run as its `files`.

    tools/spriter/.venv/bin/python tools/soundforge/pair_sketches.py                  # the missing halves, then every pair, the run and the page
    tools/spriter/.venv/bin/python tools/soundforge/pair_sketches.py all              # every new half rendered again first (about four minutes a track)
    tools/spriter/.venv/bin/python tools/soundforge/pair_sketches.py render crossing  # the named tracks' new halves alone (one process a track runs them side by side)
"""
import json
import math
import os
import shutil
import subprocess
import sys
import wave

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
from phone_sketches import Patched, phone_model  # noqa: E402

OUT = os.path.join(F.OUT_SKETCH, "pairs")
PAGE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "pair_page.html")
AUDIO = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "art", "audio")
MAP_LEVEL = F.LEVELS["music_night_shift"]       # the map's level, Night Shift's and Low Ground's

# The game's numbers, as game/audio/sound.gd and the battle screen have them.
DIP = {"contact": (-7.0, 0.7), "engage": (-9.0, 2.4), "cut": (-14.0, 1.6), "victory": (-12.0, 3.0)}
CUT_AFTER = 2.15    # the handover: the dive and the spread (1.85 s), then the scrim's 0.3 s, then the cut
CONTACT_AGAIN = 1.02   # the warning's second beat, 2 dB under the first
# Where each loop wraps to, in bars, as game/audio/sound.gd has it (LOOP_FROM): the page's switch
# loops there too.
LOOP_FROM = {"music_far_bank": 8, "music_hold_the_line": 8}
FLIP = 3.0          # a pair's crossfade either way, from ENGAGE and from BACK TO THE FIELD (Ryan, 28 October: split the difference of 2.15 and 4)

# A battle as the game plays it, in seconds of Hold The Line: the map from the top, an engage in
# the first lift, the fight on through the seven into the drum solo, back to the field, then a
# hunter's catch whose fight lands in the keys section and climbs into the climax.
RUN = [(48.0, "engage"), (116.0, "victory"), (119.0, "field"),
       (146.0, "contact"), (150.0, "engage"), (200.0, "victory"), (203.0, "field")]
RUN_END = 232.0


# ---------------------------------------------------------------- a recipe, read

def recipe_call(fn):
    """A recipe's groove call, captured rather than rendered: its form, metres, chords and voices."""
    call = {}

    def capture(*a, **kw):
        assert not a, "a recipe passes groove its arguments by name"
        call.update(kw)
        return np.zeros(1)
    with Patched(groove=capture):
        fn()
    return call



def part(call, inst, section, mode="riff", **match):
    """A recipe's pattern for a section on the first voice of `inst` in that mode that plays it
    and matches every other field given (an octave, a gain)."""
    for v in call["voices"]:
        if v["inst"] == inst and section in v["pat"] and v.get("mode", "riff") == mode and all(v.get(k, 0) == w for k, w in match.items()):
            return v["pat"][section]
    raise KeyError("no %s %s voice %s plays %s" % (mode, inst, match, section))


def spell(semis):
    return str(semis) if 0 <= semis <= 9 else F._SPELL[semis]


def roots(call, section, steps=16):
    """Each bar's chord root held through the bar, across the section's chord cycle."""
    return "".join(spell(c[0]) + "-" * (steps - 1) for c in call["chords"][section])


def door_pattern(call, sections):
    """A crash on the first step of every run of the named sections, by the loop's own step."""
    form = call["form"].replace(" ", "")   # a recipe may pass its form spaced (groove strips it)
    steps, starts, _ = F._bars(form, call.get("meter"))
    total = sum(steps)
    doors = [starts[b] for b in range(len(form)) if form[b] in sections and (b == 0 or form[b - 1] != form[b])]
    return "".join("x" if i in doors else "." for i in range(total + (1 if total % 16 == 0 else 0)))


def figure(fig, notes):
    """A one-bar figure ("r.rr.r...") on each bar's note in turn."""
    return "".join(fig.replace("r", n) for n in notes)


TICKING = {"inst": "guitar_real", "mode": "riff", "octave": 0, "params": {"clean": True}}   # the map's pulse, as Hold The Line's
QUIETER_BELLS = 0.7   # the bells 3 dB under the first cut (Ryan, 28 October: a little loud)


def no_pump(pads, most=0.1):
    """A recipe's pads with the electronic pump eased and every swell let go."""
    out = []
    for p in pads or []:
        p = dict(p)
        if p.get("pump"):
            p["pump"] = min(p["pump"], most)
        p.pop("swell", None)
        out.append(p)
    return out


# ---------------------------------------------------------------- Hold The Line's map half

def map_hold_the_line(call):
    p = lambda *a, **k: part(call, *a, **k)   # noqa: E731
    rest = lambda bars: "." * (16 * bars)   # noqa: E731
    held = lambda note, steps=16: note + "-" * (steps - 1)   # noqa: E731
    riff = p("bass_real", "N", octave=0)          # E G E F, D G F E, then the rise: four bars
    ostinato = p("guitar_real", "A", octave=-1)   # the chug's seven-step figure
    lift = p("sub_bass", "C")
    down = p("guitar_real", "M", octave=-1)
    seven = p("guitar_real", "X", octave=-1)
    unison = p("lead", "U")
    climax = p("guitar_real", "S", octave=0)
    descent = p("lead", "J")
    voices = [
        # The pulse: the chug's figures on the mechanical guitar, clean and muted, an octave
        # over the chug's, where a phone's speaker hears it.
        dict(TICKING, gain=0.2, pat={"A": ostinato, "N": ostinato, "X": seven, "U": unison, "S": climax, "R": climax, "Z": climax, "J": descent}),
        # The bass: the soft sub on the riff where the battle's bass plays it, and under the
        # cellos' riff...
        {"inst": "sub_bass", "mode": "riff", "gain": 0.4, "hold": 1.0,
         "pat": {"A": rest(4) + riff * 3, "N": riff, "C": lift, "M": down}},
        {"inst": "sub_bass", "mode": "riff", "gain": 0.28, "hold": 1.0, "pat": {"L": p("bass", "L")}},
        # ...and held on the bar's root where the battle drives the bar; Ryan's sub line in the keys.
        {"inst": "sub_bass", "mode": "riff", "gain": 0.36, "legato": True,
         "pat": {"B": "0-----------....", "X": roots(call, "X", 14), "U": roots(call, "U"), "F": p("sub_bass", "F"),
                 "W": held("7") + rest(1), "S": roots(call, "S"), "R": roots(call, "R"), "Z": roots(call, "Z"),
                 "Y": held("0"), "Q": held("0"), "J": held("0", 32)}},
        # The riff on the tine piano two octaves up, from where the battle's power chords
        # arrive; the seven an octave lower; the climax's riff in its third set, as the
        # battle's keys take it.
        {"inst": "epiano", "mode": "riff", "gain": 0.3, "octave": 2, "hold": 1.4,
         "pat": {"A": rest(8) + riff * 2, "N": riff, "Z": climax}},
        {"inst": "epiano", "mode": "riff", "gain": 0.26, "octave": 1, "hold": 1.2, "pat": {"X": seven}},
        {"inst": "epiano", "mode": "riff", "gain": 0.22, "octave": 2, "pat": {"J": descent}},
        # Ryan's tune and the keyboard solo on the piano, his harmony line on a soft horn, which
        # holds the turn's note through the bar the battle's drums fill alone.
        {"inst": "epiano", "mode": "riff", "gain": 0.36, "octave": 2, "hold": 1.0,
         "pat": {"F": p("lead", "F", octave=2), "W": held("7") + rest(1), "Y": held("7"), "K": p("epiano", "K", octave=2)}},
        {"inst": "horn_real", "mode": "riff", "gain": 0.16, "octave": 1, "legato": True,
         "pat": {"F": p("lead", "F", octave=1), "W": held("7", 32)}},
        # Spiccato cellos: the second lift's riff, the bar down, the solo's walk; a held E
        # through the turns.
        {"inst": "cello_real", "mode": "riff", "gain": 0.5, "hold": 1.6,
         "pat": {"L": p("bass", "L"), "M": down, "K": p("bass", "K"), "V": held("0"), "B": "0-----------....", "Q": held("0")}},
        {"inst": "cello_real", "mode": "riff", "gain": 0.28, "octave": 1, "legato": True, "pat": {"X": p("guitar_real", "X", octave=1)}},
        # The unison, the climax and the descent on the harp, let ring.
        {"inst": "harp", "mode": "riff", "gain": 0.48, "octave": 1, "hold": 2.5,
         "pat": {"U": unison, "S": climax, "R": climax, "Z": climax, "J": descent}},
        # The fight's metal chime is the map's bell, with its long echo (down 3 dB from the first
        # cut, Ryan, 28 October: a little loud).
        {"inst": "bell", "mode": "chord", "octave": 2, "gain": 0.1, "echo": (3, 0.4, 3), "dur": 2.5,
         "pat": {s: p("chime_metal", s, mode="chord") for s in "ACFXWRZ"}},
        # Held chords where the battle stabs: the piano on the lifts' beats and the turn, the
        # seven's long beat, the solo's bars and its breath.
        {"inst": "epiano", "mode": "stab", "gain": 0.3, "dur": 8.0, "pat": {"B": "x...............", "C": "x.......x.......", "L": "x.......x......."}},
        {"inst": "epiano", "mode": "stab", "gain": 0.26, "dur": 3.0, "pat": {"X": p("epiano", "X", mode="stab")}},
        {"inst": "epiano", "mode": "stab", "gain": 0.3, "dur": 14.0, "pat": {"K": p("epiano", "K", mode="stab"), "V": "x..............."}},
        {"inst": "epiano", "mode": "chord", "gain": 0.45, "octave": 2, "dur": 20, "pat": {"V": p("epiano", "V", mode="chord", octave=2)}},
        # A backwards swell into each section where the battle fills.
        {"inst": "swell_rev", "mode": "stab", "gain": 0.35, "dur": 2.0,
         "pat": {"B": "..............x.", "W": "." * 30 + "x.", "Y": "..............x.", "V": "..............x.", "Q": "..............x."}},
    ]
    pads = [
        # The drone under every riff section from the top, a little darker than the fight's.
        {"inst": "sweep", "gain": 0.4, "octave": 0, "rate": 0.08, "depth": 0.3, "open": 0.55, "sections": "ANSRZ", "chord": [0, 7, 12]},
        # A dark swept pad on the chords everywhere else.
        {"inst": "sweep", "gain": 0.14, "octave": 1, "rate": 0.05, "depth": 0.6, "open": 0.4, "sections": "BCLMXUFWYKVQJ"},
        {"inst": "choir_real", "gain": 0.16, "vowel": "oh", "sections": "C"},
        {"inst": "choir_real", "gain": 0.12, "vowel": "ah", "sections": "Z"},
        {"inst": "strings_real", "gain": 0.12, "sections": "RZYKV"},
    ]
    return {"kit": {}, "drums": {}, "voices": voices, "pad": pads,
            "air": (0.25, 0.1), "master": 1.1, "headroom": 0.6, "tilt": 1.5, "presence": 0.25, "low": (150.0, -6.0)}


# ---------------------------------------------------------------- the rift tracks' map halves

def map_crossing(call):
    """The Crossing's map half: the orchestra without its kit, timpani, brass or hits. Ryan's
    pattern on the electronic chug, and the breakdowns' closed-down chug, go to the ticking
    guitar; the plucked strings stay the engine, a little under; the engine sections' horn
    stabs are held as soft chords; the choir's pump eased and the tuttis flat."""
    voices = []
    for v in call["voices"]:
        if v["inst"] in ("brass", "hit"):
            continue
        v = dict(v)
        if v["inst"] == "e_chug":
            v = dict(TICKING, gain=0.24 if "B" in v["pat"] else 0.2, pat=v["pat"])
        elif v["inst"] == "pizz":
            v["gain"] = 0.34
        elif v["inst"] in ("bell", "bell_stutter"):
            v["gain"] = round(v["gain"] * QUIETER_BELLS, 3)
        elif v["inst"] == "horn" and v.get("mode") == "chord" and v.get("dur") == 4:
            v.update(dur=8, gain=0.16)
        voices.append(v)
    return {"kit": {}, "drums": {}, "voices": voices, "pad": no_pump(call["pad"]), "crescendo": None, "air": (0.3, 0.12)}


def map_far_bank(call):
    """The Far Bank's map half: the orchestra without its kit, timpani or hits; the climax at one
    level (its leads keep their rotation, not its crescendo) and the closer still letting go into
    the wrap; the bells and the backwards swells under; the choir's pump eased and the pads' swells
    let go."""
    voices = []
    for v in call["voices"]:
        if v["inst"] == "hit":
            continue
        v = dict(v)
        if v["inst"] in ("bell", "bell_stutter"):
            v["gain"] = round(v["gain"] * QUIETER_BELLS, 3)
        elif v["inst"] == "swell_rev":
            v["gain"] = 0.6
        voices.append(v)
    return {"kit": {}, "drums": {}, "voices": voices, "pad": no_pump(call["pad"]), "crescendo": {"G": (0.85, 0.85), "H": (0.9, 0.35)}}


# ---------------------------------------------------------------- Full Bore's map half

def map_full_bore(call):
    """Full Bore's map half: no kit; the driven riff on the soft sub with the ticking guitar on
    its chug, the driven bass's answers and the breakdown's line on cellos, the clean bass kept
    (it was never driven), the keys' tapped melody on the piano a little under, the synth lead's
    answer in the seven on a soft horn and its unison riff on the harp, the chime for the bell,
    bowed strings where the guitars rang; the drone darker."""
    voices = []
    for v in call["voices"]:
        inst, mode, v = v["inst"], v.get("mode", "riff"), dict(v)
        if inst == "bass_real" and mode == "riff":
            if v["gain"] >= 0.8:
                v = {"inst": "sub_bass", "mode": "riff", "gain": 0.4, "hold": 1.0, "pat": v["pat"]}
            else:
                v = {"inst": "cello_real", "mode": "riff", "gain": 0.34, "hold": 1.4, "pat": v["pat"]}
        elif inst == "guitar_real":
            if v["gain"] < 0.5:
                continue   # the second chug, the fifth above: one ticking guitar is enough
            v = dict(TICKING, gain=0.2, pat=v["pat"])
        elif inst in ("bass", "guitar_hold") or (inst == "bass_real" and mode == "chord"):
            continue       # the crunch synth, the ringing guitars and the driven roots are the fight's
        elif inst == "synlead":
            if "X" in v["pat"]:
                v = {"inst": "horn_real", "mode": "riff", "gain": 0.18, "octave": 2, "pat": {"X": v["pat"]["X"]}}
            else:
                v = {"inst": "harp", "mode": "riff", "gain": 0.4, "octave": 1, "hold": 2.5, "pat": v["pat"]}
        elif inst == "chime_metal":
            v.update(inst="bell", gain=0.1, echo=(3, 0.4, 3), dur=2.5)
        elif inst == "sub_bass":
            v["params"] = dict(v.get("params", {}), punch=0.0)
        elif inst in ("epiano", "bass_clean"):
            v["gain"] = round(v["gain"] * 0.8, 3)
        voices.append(v)
    voices.append({"inst": "swell_rev", "mode": "stab", "gain": 0.35, "dur": 2.0, "pat": {"B": "..............x."}})
    pads = [dict(p, gain=round(p["gain"] * 0.85, 3), open=0.55) if p["inst"] == "sweep" else dict(p) for p in call["pad"]]
    pads.append({"inst": "strings_real", "gain": 0.1, "sections": "XCD"})
    return {"kit": {}, "drums": {}, "drum_gain": None, "voices": voices, "pad": pads,
            "air": (0.25, 0.1), "master": 1.1, "headroom": 0.6, "low": (150.0, -6.0)}


# ---------------------------------------------------------------- the calm tracks' battle halves

def fight_kit():
    """The human fight's kit, Hold The Line's voices, a touch under its levels."""
    return {"kick": (F.variants(F.kick_real), 1.3), "snare": (F.variants(F.snare_real), 0.85),
            "hat": (F.variants(lambda p: F.hat_real(False, p)), 0.48), "open": ([F.hat_real(True)], 0.42),
            "crash": ([F.crash_real()], 0.62), "china": (F.china(), 0.75), "ride": ([F.ride_real()], 0.4),
            "stack": ([F.stack()], 0.65), "tom": (F.variants(lambda p: F.tom_real(130.0, p)), 1.1),
            "tom2": (F.variants(lambda p: F.tom_real(98.0, p)), 1.1)}


def battle_night_shift(call):
    """Night Shift's battle half: the human calm as a fight. The kick stays on every beat with a
    full backbeat over it (the industrial four on the floor), the mechanical guitar's eighths
    driven into the chug and the sub's pulse doubled by the driven bass; the dark synth's riff
    (Hold The Line's first riff, the map half's one dark section) on chug, driven bass and the
    crunch synth in unison over a kick in eighths; the lead's long notes on the lead guitar; a
    half-time breakdown on ringing chords under the choir; the drone under every groove section.
    The piano off the beat and the chime's hook stay, since they are the track. The outro keeps the
    chug and the drone over the kick on one and three rather than thinning, since the calm lives in
    the map half."""
    p = lambda *a, **k: part(call, *a, **k)   # noqa: E731
    riff = p("bass", "D", gain=0.34)
    pulse = {s: p("sub_bass", s, gain=0.4) for s in "IACRD"}
    eighths = {"I": "0.0.0.0.0.0.0.0.", "A": p("guitar_real", "A"), "R": p("guitar_real", "R"), "C": p("guitar_real", "C"), "D": riff,
               "O": figure("r.r.r.r.r.r.r.r.", [spell(c[0]) for c in call["chords"]["O"]])}
    voices = []
    for v in call["voices"]:
        inst, v = v["inst"], dict(v)
        if inst == "guitar_real" or (inst == "bass" and "D" in v["pat"]):
            continue   # the mechanical guitar and the dark synth's riff are the fight's voices below
        if inst == "brass":
            v["gain"] = 0.24
        elif inst == "chime_metal":
            v["gain"] = 0.2
        elif inst == "sub_bass" and "A" in v["pat"]:
            v["gain"] = 0.24   # the pulse under the driven bass
        elif inst == "lead":
            v.update(inst="lead_real", gain=0.3)
        voices.append(v)
    voices += [
        # The chug: the mechanical guitar's eighths through the wall of gain, the riff in its section.
        {"inst": "guitar_real", "mode": "riff", "gain": 0.72, "octave": -1, "pat": eighths},
        # The driven bass on the sub's pulse, on the riff, and held under the breakdown and the outro.
        {"inst": "bass_real", "mode": "riff", "gain": 0.38, "hold": 1.1, "params": {"drive": 3.5}, "pat": dict(pulse, D=riff)},
        {"inst": "bass_real", "mode": "riff", "gain": 0.32, "legato": True, "params": {"drive": 3.5}, "pat": {"B": p("sub_bass", "B"), "O": roots(call, "O")}},
        {"inst": "bass", "mode": "riff", "gain": 0.3, "hold": 1.0, "params": {"drive": 3.5, "cutoff": 900.0}, "pat": {"D": riff}},
        # Ringing chords through the breakdown.
        {"inst": "guitar_hold", "mode": "stab", "gain": 0.6, "dur": 16, "pat": {"B": "x..............."}},
    ]
    door = door_pattern(call, "IABCDRO")
    drums = {
        "kick": {"I": "x...x...x...x...", "A": "x...x...x...x...", "B": "x.....x.........", "C": "x...x...x...x...",
                 "D": "x.x.x.x.x.x.x.x.", "R": "x...x...x...x...", "O": "x.......x......."},
        "snare": {"I": "....x.......x...", "A": "....x.......x...", "B": "........x.......", "C": "....x.......x...",
                  "D": "....x.......x...", "R": "....x.......x...", "O": "....x.......x..."},
        "hat": {"I": "x.x.x.x.x.x.x.x.", "A": "x.x.x.x.x.x.x.x.", "B": "x...x...x...x...", "D": "xxxxxxxxxxxxxxxx",
                "R": "x.x.x.x.x.x.x.x.", "O": "x.x.x.x.x.x.x.x."},
        "open": {"A": "..x...x...x...x.", "R": "..x...x...x...x."},
        "ride": {"C": "x.x.x.x.x.x.x.x."},
        "crash": {"*": door},
        "china": {"A": "." * 62 + "x.", "C": "." * 62 + "x.", "R": "." * 62 + "x.", "D": "..............x."},
        "stack": {"D": "..x...x...x...x."},
        "tom": {"B": "." * 112 + "....x.x.xx.x.x.."},
        "tom2": {"B": "." * 112 + "......x.....x.xx"},
    }
    pads = [
        # The drone Ryan likes under the human tracks, under every groove section.
        {"inst": "sweep", "gain": 0.45, "octave": 0, "rate": 0.08, "depth": 0.3, "open": 0.75, "sections": "IACDRO", "chord": [0, 7, 12]},
        {"inst": "choir_real", "gain": 0.22, "vowel": "oh", "sections": "B"},
    ]
    return {"kit": fight_kit(), "drums": drums, "voices": voices, "pad": pads,
            "air": (0.12, 0.06), "master": 1.1, "headroom": 0.6, "tilt": 1.5, "presence": 0.25, "low": (150.0, -6.0)}


def battle_low_ground(call):
    """Low Ground's battle half: the rift calm as a fight, in its own twelve-eight. The ground
    (A G F E, the Andalusian cadence) goes into the chugged guitar and the driven bass under the
    cellos that carry it: a shuffle on each beat through the variations, held chords for the
    intro, the horns' chorale and the outro, quarters for the stripped variation, and the full
    triplets in the tutti. The orchestral bass drum and a full backbeat under it, timpani on the
    beats, brass on the chorale's and the tutti's beats, an orchestral hit at the tutti's door;
    every variation's own voice (the bells, the harp, the horns, the violins, the sub's pulse) as
    the map half has it."""
    ground = "55331100"   # A A G G F F E E, a bar each
    held, shuffle, quarters, triplets = "r-----r-----", "r.rr.rr.rr.r", "r..r..r..r..", "rrrrrrrrrrrr"
    chug = {"I": figure("r-----------", "5555"), "A": figure(shuffle, ground), "B": figure(shuffle, ground), "C": figure(held, ground),
            "D": figure(shuffle, ground), "E": figure(triplets, ground), "F": figure(quarters, ground), "O": figure(held, "5533")}
    voices = [dict(v) for v in call["voices"]] + [
        {"inst": "guitar_real", "mode": "riff", "gain": 0.7, "octave": -1, "pat": chug},
        {"inst": "bass_real", "mode": "riff", "gain": 0.36, "hold": 1.1, "params": {"drive": 3.5}, "pat": chug},
        {"inst": "brass", "mode": "stab", "gain": 0.24, "dur": 3, "pat": {"C": "x.....x.....", "E": "x.....x....."}},
        {"inst": "hit", "mode": "stab", "gain": 0.35, "dur": 3, "pat": {"E": "x" + "." * 95}},
    ]
    door = door_pattern(call, "IABCDEFO")
    drums = {
        "kick": {"I": "x.....x.....", "A": "x.....x.....", "B": "x.....x..x..", "C": "x.....x.....", "D": "x.....x..x..",
                 "E": "x..x..x..x..", "F": "x.....x.....", "O": "x.....x....."},
        "snare": {"A": "...x.....x..", "B": "...x.....x..", "C": "......x.....", "D": "...x.....x..", "E": "...x.....x..",
                  "F": "......x.....", "O": "......x....."},
        "hat": {"A": "x..x..x..x..", "B": "x.xx.xx.xx.x", "C": "x..x..x..x..", "D": "x.xx.xx.xx.x", "E": "x.xx.xx.xx.x",
                "F": "x..x..x..x..", "O": "x..x..x..x.."},
        "crash": {"*": door},
        "china": {"D": "." * 21 + "x..", "E": "." * 21 + "x.."},
        "timp": {"I": "x.....x.....", "C": "x...........", "D": "x.....x.....", "E": "x.....x.....", "O": "x" + "." * 35 + "x.x.x.x.x.x."},
    }
    kit = {"kick": (F.variants(F.bassdrum_real), 1.25), "snare": (F.variants(F.snare_real), 0.8),
           "hat": (F.variants(lambda p: F.hat_real(False, p)), 0.36), "crash": ([F.crash_real()], 0.6), "china": (F.china(), 0.6),
           "timp": (F.variants(lambda p: F.timpani_real()), 0.85)}
    return {"kit": kit, "drums": drums, "voices": voices, "air": (0.25, 0.1), "low": (150.0, -5.0)}


# ---------------------------------------------------------------- the six pairs

# track -> its title, its shipped half, the recipe both halves share, the new half's arrangement
# (overrides on the recipe's groove call) and its level, read through the phone model (28
# October): a map half where the map tracks sit there (-28 to -30 dB), a battle half where Hold
# The Line's does (-22.4). Full Bore's map half keeps more of itself in the phone's band than the
# others, so it sits under the map's level; Night Shift's battle half a dB under the fight's. A
# rift track's map half has no orchestral kick, where most of its battle half's power is and a
# phone plays little of it, so at the map's level it read as loud as its battle half on the
# phone: it sits 3 dB under its battle half there (The Crossing's -28.7, The Far Bank's -30),
# until the rift tracks are levelled against Hold The Line (the bible's open levelling row). Low Ground's
# chugs and kit put its battle half in the phone's band, so it sits under the rift tracks'
# level, not over it as The Crossing does (28 October: at The Crossing's -17.7 it read -18.8).
PAIRS = {
    "hold_the_line": {"title": "Hold The Line", "shipped": "battle", "recipe": F.music_hold_the_line, "arrange": map_hold_the_line, "level": MAP_LEVEL},
    "night_shift": {"title": "Night Shift", "shipped": "map", "recipe": F.music_night_shift, "arrange": battle_night_shift, "level": -21.7},
    "full_bore": {"title": "Full Bore", "shipped": "battle", "recipe": F.music_full_bore, "arrange": map_full_bore, "level": -27.4},
    "far_bank": {"title": "The Far Bank", "shipped": "battle", "recipe": F.music_far_bank, "arrange": map_far_bank, "level": -28.8},
    "low_ground": {"title": "Low Ground", "shipped": "map", "recipe": F.music_low_ground, "arrange": battle_low_ground, "level": -21.3},
    "crossing": {"title": "The Crossing", "shipped": "battle", "recipe": F.music_crossing, "arrange": map_crossing, "level": -28.3},
}


def new_half(track):
    return "map" if PAIRS[track]["shipped"] == "battle" else "battle"


def render_new_half(track):
    """The track's new half on its recipe's groove call, levelled as the forge levels a loop."""
    t = PAIRS[track]
    name = "music_%s_%s" % (track, new_half(track))
    F.seed(name)
    call = recipe_call(t["recipe"])
    kw = dict(call)
    kw.update(t["arrange"](call))
    return F.limit(F.write_level(F.groove(**kw), name, t["level"]))


# ---------------------------------------------------------------- the files

def read_wav(path):
    with wave.open(path, "rb") as w:
        return np.frombuffer(w.readframes(w.getnframes()), "<i2") / 32767.0


def write(name, x, kbps=256, aac=True):
    """A WAV (mono, or stereo for a list of two) and its AAC in an MP4, into OUT. Stereo is coded
    as two channels with nothing shared between them."""
    os.makedirs(OUT, exist_ok=True)
    chans = x if isinstance(x, list) else [x]
    pcm = np.stack([(np.clip(c, -1.0, 1.0) * 32767.0).astype("<i2") for c in chans], axis=1)
    wav = os.path.join(OUT, name + ".wav")
    with wave.open(wav, "wb") as w:
        w.setnchannels(len(chans))
        w.setsampwidth(2)
        w.setframerate(F.SR)
        w.writeframes(pcm.tobytes())
    if not aac:
        return wav
    m4a = os.path.join(OUT, name + ".mp4")
    apart = ["-aac_ms", "0", "-aac_is", "0", "-aac_pns", "0"] if len(chans) > 1 else []
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-c:a", "aac", "-b:a", "%dk" % kbps] + apart
                   + ["-movflags", "+faststart", m4a], check=True, capture_output=True)
    return m4a


def halves(track):
    """The track's map and battle halves, the shipped one from art/audio and the new one from OUT."""
    shipped = read_wav(os.path.join(AUDIO, "music_%s.wav" % track))
    new = read_wav(os.path.join(OUT, "%s_%s.wav" % (track, new_half(track))))
    if len(shipped) != len(new):
        raise ValueError("%s: the new half is %d samples, the shipped one %d: not one timeline" % (track, len(new), len(shipped)))
    return (new, shipped) if new_half(track) == "map" else (shipped, new)


def effects_of(events):
    """The effects a run plays, as (seconds, name, dB): the warning's two beats, the engage and
    its cut, the victory."""
    out = []
    for when, what in events:
        if what == "contact":
            out += [(when, "contact", 0.0), (when + CONTACT_AGAIN, "contact", -2.0)]
        elif what == "engage":
            out += [(when, "engage", 0.0), (when + CUT_AFTER, "cut", 0.0)]
        elif what == "victory":
            out.append((when, "victory", 0.0))
    return sorted(out)


def gains(n, events):
    """The music's two gains through a run, the map's and the battle's, each sample: an equal
    power crossfade (Sound._fade_to's cosine and sine) over each change, and the dips the game
    applies on top (Sound._dip: a 30 ms drop, a quadratic climb back, a new dip taking over
    from wherever the last one is)."""
    t = np.arange(n) / F.SR
    battle = np.zeros(n)
    for when, what in events:
        if what in ("engage", "field"):
            x = np.clip((t - when) / FLIP, 0.0, 1.0)
            battle = np.where(t >= when, x if what == "engage" else 1.0 - x, battle)
    dip = np.zeros(n)
    for when, name, _db in effects_of(events):
        if name not in DIP:
            continue
        depth, recover = DIP[name]
        i = int(when * F.SR)
        now, low = float(dip[i]), min(float(dip[i]), depth)
        s = t[i:] - when
        u = np.clip((s - 0.03) / recover, 0.0, 1.0)
        dip[i:] = np.where(s < 0.03, now + (low - now) * s / 0.03, low * (1.0 - u * u))
    g = 10.0 ** (dip / 20.0)
    return np.cos(battle * math.pi / 2.0) * g, np.sin(battle * math.pi / 2.0) * g


def run(map_x, battle_x):
    """The run: both halves through their gains, the effects at their files' levels over them
    (the game's knobs at their defaults, every bus at 0 dB), three seconds faded at the end."""
    n = int(RUN_END * F.SR)
    gm, gb = gains(n, RUN)
    x = map_x[:n] * gm + battle_x[:n] * gb
    effects = effects_of(RUN)
    fx = np.zeros(n + F.SR * 5)
    for when, name, db in effects:
        s = read_wav(os.path.join(AUDIO, name + ".wav")) * 10.0 ** (db / 20.0)
        i = int(when * F.SR)
        fx[i:i + len(s)] += s
    x = x + fx[:n]
    x[-F.SR * 3:] *= np.linspace(1.0, 0.0, F.SR * 3)
    return x, effects


def padded(x):
    # A power of two long: the forge's filters are whole-file FFTs, slow on a length with a large
    # prime factor (a track's), and the padding keeps the filters' wrap off the music.
    return np.concatenate([x, np.zeros((1 << int(math.ceil(math.log2(len(x))))) - len(x))])


def measure(name, x):
    return {"name": name, "mean_db": round(F.mean_level(x), 1), "phone_db": round(F.mean_level(phone_model(padded(x))[:len(x)]), 1),
            "peak_db": round(20.0 * math.log10(float(np.max(np.abs(x))) + 1e-9), 1), "under_150": round(F.low_share(padded(x)), 2)}


def bar_times(name):
    m = F.MUSIC[name]
    form = m["form"].replace(" ", "")
    steps, _, scales = F._bars(form, m.get("meter"))
    return np.concatenate([[0.0], np.cumsum([s * k * 15.0 / m["bpm"] for s, k in zip(steps, scales)])])[:-1]


def main(argv):
    os.makedirs(OUT, exist_ok=True)
    if argv[:1] == ["render"]:
        for track in argv[1:]:
            x = render_new_half(track)
            path = write("%s_%s" % (track, new_half(track)), x, aac=False)
            print("%-14s %-6s %6.2f s  %s" % (track, new_half(track), len(x) / F.SR, os.path.relpath(path)))
        return 0
    for track in PAIRS:
        if argv[:1] == ["all"] or not os.path.exists(os.path.join(OUT, "%s_%s.wav" % (track, new_half(track)))):
            main(["render", track])
    tracks = []
    for track, t in PAIRS.items():
        map_x, battle_x = halves(track)
        write("%s_pair" % track, [map_x, battle_x], kbps=384)
        name = "music_" + track
        runs, total = F.sections(name)
        levels = [measure("map", map_x), measure("battle", battle_x)]
        tracks.append({"id": track, "title": t["title"], "new": new_half(track), "bpm": F.MUSIC[name]["bpm"], "length": round(total, 3),
                       "loop_from_bar": 1 + int(LOOP_FROM.get(name, 0)), "bar_at": [round(float(b), 4) for b in bar_times(name)],
                       "sections": [{"section": s, "bars": [b0, b1], "at": round(at, 2), "what": what} for s, b0, b1, at, what in runs],
                       "levels": levels})
        print("%-14s map %6.1f dB (phone %6.1f)  battle %6.1f dB (phone %6.1f)" % (track, levels[0]["mean_db"], levels[0]["phone_db"], levels[1]["mean_db"], levels[1]["phone_db"]))
    x, effects = run(*halves("hold_the_line"))
    write("hold_the_line_run", x)
    manifest = {"tracks": tracks, "flip": FLIP,
                "run": {"track": "hold_the_line", "events": [{"at": w, "what": e} for w, e in RUN],
                        "effects": [{"at": round(w, 2), "name": nm, "db": db} for w, nm, db in effects], "end": RUN_END}}
    with open(os.path.join(OUT, "manifest.json"), "w") as f:
        json.dump(manifest, f, indent=1)
    shutil.copyfile(PAGE, os.path.join(OUT, "index.html"))
    print(os.path.relpath(OUT))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

"""Night Shift's ninth round as a pair (Ryan, 2 November, on the eighth): the tenth, and the bass down.

  "Night shift - the tenth up is good, and maybe bring the bass down 3db. Actually I'd like to hear
  the whole track with driven bass down 3 db everywhere."

In R the guitar plays a tenth over the bass, an octave and a third along E minor, an approach note
off the scale a minor third up. The driven bass is 3 dB down wherever it plays: the walk, the hold
under the two synth lines, the breakdown's held roots; a set puts the return beside the bass as it
was.

Kept from the earlier rounds: the battle half as a jam in turns of two bars, the walk with the
arpeggio or the hook and never both, the hold under the two together on three-three-two 6 dB down,
the outro's hold into the top; the synth lines' voicings by job (the arpeggio highlighted on the
plucked string in the intro and the outro, the hook pushed on the synth lead over the arpeggio on
the FM synth in the head and the return, the arpeggio behind the lead guitar on the synth lead, the
hook answering the walk on the FM synth); the intro on three-three-two all through; D the piano's
turn and the factory's blended, the riff dark and low as the map's nod; the map half (the intro
without its front), no crash at the top and no drone, the drums elsewhere (Night Shift's four on
the floor under Hold The Line's density, the map's industry over the kit), the breakdown's held
roots and ringing chords, the piano off the beat, the chime's hook, the lead's long notes on the
lead guitar, the choir.

    tools/spriter/.venv/bin/python tools/soundforge/night_sketches.py          # the set and the full pair, then night9.json beside the pairs
    tools/spriter/.venv/bin/python tools/soundforge/night_sketches.py b        # the named sets only (b, and full for the pair)
"""
import json
import os
import sys
from concurrent.futures import ProcessPoolExecutor

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import pair_sketches as P  # noqa: E402
from hold_sketches import copied, master_together, run_steps  # noqa: E402

NAME = "music_night_shift"
MAP_LEVEL = F.LEVELS[NAME]
BATTLE_LEVEL = P.PAIRS["night_shift"]["level"]


# ---------------------------------------------------------------- the map half

def map_intro(call):
    """The shipped map with its front cut (Ryan: don't start with the sub and the drone, it breaks
    the loop; the drone's crescendo from about 0:10 works): the sub's pulse joins at the intro's
    fifth bar, and the pad is silent for three bars and fades in through the fourth, where its
    slow filter is at its darkest, so from 0:10 it opens just as it did."""
    kw = copied(call)
    for v in kw["voices"]:
        if v["inst"] == "sub_bass" and "I" in v["pat"]:
            v["pat"]["I"] = "." * 64 + v["pat"]["I"] * (64 // len(v["pat"]["I"]))
    for p in kw["pad"]:
        if "I" in p.get("sections", ""):
            p["enter"] = {"I": (3, 1)}
    return kw


# ---------------------------------------------------------------- the battle half

def bars(*xs):
    return "".join(xs)


FILL_TOM, FILL_TOM2 = "....x.x.xx.x.x..", "......x.....x.xx"   # Hold The Line's fill, in a phrase's last bar
GROOVE_KICK = bars("x...x...x...x..x", "x...x..xx...x...", "x...x...x...x..x", "x...x..xx...x.x.",
                   "x...x...x...x..x", "x...x..xx...x...", "x...x...x...x..x", "x...x...x.......")
LEAD_KICK = bars("x...x...x...x..x", "x..x..x.x...x...", "x...x...x...x..x", "x..x..x.x...x.x.",
                 "x...x...x...x..x", "x..x..x.x...x...", "x...x...x...x..x", "x...x...x.......")
GROOVE_SNARE = bars("....x..o....x..o", "....x..o.o..x...", "....x..o....x..o", "....x..o.o..x.o.",
                    "....x..o....x..o", "....x..o.o..x...", "....x..o....x..o", "....x.......x...")
HATS = "xx.xxx.xxx.xxx.x" * 7 + "xx.xxx.x........"   # sixteenths round the open hat, out for the fill
OPENS = "..x...x...x...x." * 7 + "..x...x........."
FILLS = {"tom": "." * 112 + FILL_TOM, "tom2": "." * 112 + FILL_TOM2}

# The second round's groove, one bar on each chord's root: the hold's.
THREE_THREE_TWO = "r..r..r.r..r..r."
EIGHTHS = "r.r.r.r.r.r.r.r."   # round one's chug

# The bass line's notes for each chord as (root, its octave, its fifth, the passing note into the
# next chord), on the driven bass an octave down (0 is E1).
CHORD_NOTES = {   # by the chord's root and the next chord's root
    (0, 8): ("0", "c", "7", "7"), (8, 10): ("8", "e", "c", "9"), (10, 7): ("a", "j", "f", "8"), (7, 0): ("7", "i", "d", "l"),
    (0, 5): ("0", "c", "7", "4"), (5, 3): ("5", "f", "c", "4"), (3, -2): ("3", "e", "a", "9"), (-2, 0): ("a", "j", "f", "l"),
    (0, 0): ("0", "c", "7", "l"), (8, 7): ("8", "e", "c", "8"),
    (0, -2): ("0", "c", "7", "9"), (-2, 3): ("a", "j", "f", "2"), (3, 0): ("3", "e", "a", "l"),   # D's Em D G
}


def line_bar(fig, root, next_root):
    """The bass line's bar on a groove before the next chord (the second round's): a hit by the and
    of two takes the octave, one by the a of three the fifth, the bar's last hit from beat four the
    passing note, the rest the root; a hit with room after it holds two steps."""
    root_, octave, fifth, passing = CHORD_NOTES[root, next_root]
    hits = [i for i, c in enumerate(fig) if c == "r"]
    bar = ["."] * 16
    for j, h in enumerate(hits):
        last = j == len(hits) - 1
        bar[h] = passing if last and h >= 12 else octave if 6 <= h <= 7 else fifth if 11 <= h <= 13 else root_
        if (16 if last else hits[j + 1]) - h >= 3:
            bar[h + 1] = "-"
    return "".join(bar)


# The hold under the hook and the arpeggio together, a bar's guitar and bass on its chord's root
# before the next chord's (Ryan: "back to holding the rhythm and chords like your first take"):
# three-three-two, the guitar on the root and the bass on its line (the second round's groove, the
# third round's first row), or round one's eighths on the root.
HOLDS = {
    "332": (lambda r, n: P.figure(THREE_THREE_TWO, [P.spell(r)]), lambda r, n: line_bar(THREE_THREE_TWO, r, n)),
    "eighths": (lambda r, n: P.figure(EIGHTHS, [P.spell(r)]), lambda r, n: P.figure(EIGHTHS, [P.spell(r)])),
}
HOLD = 0.5   # the hold 6 dB under the walk ("and go down in volume")

# The jam's rhythms (Ryan, 30 October): the two he kept of the second round's grooves and his four
# from the Melody Desk, a bar's hits in sixteenths. The third round's pull-backs are gone (the root
# held under a pickup was "too jarringly slow"); the hold under both synth lines makes the room.
RHYTHMS = {
    "332": "x..x..x.x..x..x.",       # three, three, two
    "gallop": "x.xx..x.x.xx..x.",    # pairs of sixteenths pushing into the beat
    "pairs": "xx.xx.xx.xx.x.x.",     # his first
    "offbeats": "xx.x.x.x.x.xx.x.",  # his second
    "bursts": "xxx..x.x.x..xxx.",    # his third
    "threes": "xxx..xxx..x.xxx.",    # his fourth
}

# Each rhythm's figures: the line's notes on its hits as steps along E minor from the bar's chord
# root (0 the root, 4 its fifth, 7 its octave), "A" and "V" a semitone under and over the next
# chord's root, "b" the blues note (E minor's flat fifth, for E's bars alone).
FIGURES = {
    "332": {"home": [0, 0, 0, 0, 0, 0], "lift": [0, 0, 7, 0, 4, "A"], "climb": [0, 2, 3, 4, 6, 7]},
    "gallop": {"drive": [0, 0, 0, 7, 0, 0, 0, "A"], "octs": [0, 7, 7, 0, 0, 7, 7, "V"], "walk": [0, 0, 2, 3, 4, 4, 6, "A"]},
    "pairs": {"pops": [0, 7, 0, 7, 0, 7, 0, 7, 4, "A"], "stairs": [0, 0, 2, 2, 3, 3, 4, 4, 6, "A"], "fall": [7, 7, 6, 6, 4, 4, 2, 2, 0, "V"]},
    "offbeats": {"run": [0, 0, 2, 3, 4, 6, 7, 4, "A"], "zigzag": [0, 7, 0, 6, 0, 4, 0, 2, "A"], "blues": [0, 0, 2, 3, "b", 4, 6, 7, "A"]},
    "bursts": {"turn": [0, 1, 0, 4, 6, 7, 6, 4, "A"], "chug": [0, 0, 0, 7, 0, 7, 0, 0, "A"], "rise": [0, 2, 4, 7, 4, 2, 0, 2, "A"]},
    "threes": {"octs": [0, 0, 7, 0, 0, 7, 4, 0, 0, "A"], "steps": [0, 2, 3, 4, 3, 2, 7, 6, 4, "A"], "climb": [0, 0, 0, 2, 2, 2, 4, 6, 7, "A"]},
}

# The battle half in turns of two bars (Ryan, 30 October: "Jam session, everybody gets a turn, we
# keep it moving, we try different additions at different points"): what the guitar and the bass
# play, a rhythm and its figure (the walk) or the hold, and the synth lines over it, the walk with
# the arpeggio or the hook, never both; the intro sets the tone on three-three-two and never walks
# (Ryan, 30 October: "not straying too far from 3-3-2 - its setting the tone"; "3-3-2 all through
# wins"). A synth line's turn names its voicing after the colon (VOICINGS). The chords run Em C D Bm
# Em A G D through A, C and R, E minor through the intro, Em Em D G through D and Em C Bm Em through
# the outro; the breakdown (B) keeps its own voices.
TURNS = {
    "I": [("332.home", ""), ("332.home", ""), ("332.home", "arp:high"), ("332.home", "arp:high")],   # on the root: "Intro I shouldn't walk"
    "A": [("hold", "both:push")] * 4 + [("offbeats.run", "hook:back"), ("gallop.drive", "hook:back"), ("bursts.rise", "hook:back"), ("threes.octs", "hook:back")],
    "C": [("332.lift", ""), ("pairs.pops", ""), ("gallop.walk", ""), ("threes.climb", ""),   # under the lead guitar's long notes
          ("offbeats.zigzag", "arp:back"), ("bursts.chug", "arp:back"), ("pairs.stairs", "arp:back"), ("threes.steps", "arp:back")],
    "D": [("332.home", "")] * 4,
    "R": [("pairs.pops", "hook:push"), ("gallop.octs", "hook:push"), ("bursts.turn", "hook:push"), ("threes.climb", "hook:push")],
    "O": [("hold", "both:high")] * 4,
}
# The synth lines' voicings, (the arpeggio's voice, the hook's), each picked for its job (Ryan, 30
# October: "When the arpeggio is taking a backseat, the synth lead works best. When we want to push
# the hook, the swapped version is best. When we want to highlight the arpeggio, either the plucked
# or tine are great ... The plucked is certainly more unique"): the arpeggio behind on the synth
# lead, the hook pushed on the synth lead over the arpeggio on the FM synth, the arpeggio
# highlighted on the plucked string, the hook otherwise on the FM synth.
VOICINGS = {"back": ("lead", "fm"), "push": ("fm", "lead"), "high": ("pluck", "fm")}
UP = "R"   # the later spot where the guitar leaves the bass's octave ("save the octave-up for a later spot")

# D, the dark synth's section, plays Hold The Line's first riff, which the map half voices as a nod
# (the crunch synth dark and low) and the battle's first rounds voiced as Hold The Line's own riff
# section (the riff on the driven bass and the crunch synth over the guitar's chug, the gallop on
# the kick, a double-kick run out). Ryan, 30 October: "night shift D is a subtle nod to Hold the
# Line in the Map version, but essentially a straight copy in the battle version. It needs to do
# something different." So the riff goes back to the map's nod and D takes a turn of its own, on
# Night Shift's four on the floor with the map's sixteenths on the hat: the house piano stabbing
# the chords in three-three-two over the hold ("piano"), the riff alone on the crunch synth an
# octave up answered by the walk two bars at a time ("trade"), or the industry's knocks, clanks
# and ticks on three-three-two over the hold ("factory"); "copy" is the fourth round's. The hold is
# the head's, 6 dB down, since the turn is another voice's. The chords run Em Em D G twice.
D_TURNS = {
    "copy": [("332.home", "")] * 4,
    "piano": [("hold", "")] * 4,
    "trade": [("rest", ""), ("pairs.pops", ""), ("rest", ""), ("threes.climb", "")],
    "factory": [("hold", "")] * 4,
    "blend": [("hold", "")] * 4,
}
# The piano's turn and the factory's blended (Ryan, 30 October: "can we blend the piano take with
# the factory take (elegantly)?"; 31 October: "go blended for D"): the piano's three-three-two a
# little under its own turn, the knocks in its gaps a step before each of its hits, a clank every
# second bar, the ticks soft.
D_PLAN = "blend"
PIANO_BLEND = 0.5
BLEND_KNOCK = "..c..c....c..c.."
BLEND_CLANK = "." * 16 + ".......c........"
BLEND_TICK = "5" * 16
# Each turn's levels keep D within about 2 dB of the fourth round's on a phone's speaker, since a
# battle half holds its level (the bible's pair row): the piano and the industry lead their turns,
# the nod sits 5 dB under the piano, the call meets the walk's answers.
NOD = {"gain": 0.67, "hold": 1.0, "params": {"drive": 2.5, "cutoff": 600.0}}   # the map's dark synth, opened a little for a phone
PIANO_D = 0.6   # each of the piano's three chord tones
CALL = 0.55   # the riff's call when D trades
FACTORY = "h"   # the industry's hits when D is the factory's, 1.8 of full
D_DRUMS = 1.4   # the kit in D on four on the floor, which strikes the kick less often than the gallop did
# The guitar over the bass in the later spot (Ryan, 30 October: "can we do a two-octave separation
# instead of messing with volumes?"; 31 October: "The octave split - still isn't doing it for me.
# Maybe octave isnt the right call after all. Try 5ths and some others?"): the walk's notes moved by
# an interval, (the guitar's octave, the move in semitones, or ("steps", k) along E minor with a note
# off the scale moved a minor third), at the unison guitar's level.
SPLITS = {
    "octave": (0, 0),            # the third round's
    "two octaves": (1, 0),       # the seventh's
    "fifth": (-1, 7),            # in the bass's own register: the power chord's fifth
    "fourth": (-1, 5),
    "tenth": (0, ("steps", 2)),  # an octave and a third, the twin guitars' harmony
    "twelfth": (0, 7),           # an octave and a fifth
}
UP_SPLIT = "tenth"   # Ryan, 2 November: "the tenth up is good"
UP_GAIN = 0.45
# The driven bass down wherever it plays (Ryan, 2 November: "maybe bring the bass down 3db.
# Actually I'd like to hear the whole track with driven bass down 3 db everywhere").
BASS_DB = -3.0
ARP = "0123432101234321"   # up and down two octaves of the chord in sixteenths

# The synth lines' voices (Ryan, 30 October: "The hook is hard to hear over the arpeggios. Maybe
# instead of lead an octave up, another voice?"): the arpeggio two octaves up and the hook an octave
# under the chime, each new voice at the phone level of the line's fourth-round voice.
ARP_VOICES = {
    "lead": {"inst": "lead", "gain": 0.16},      # the synth lead, the fourth round's
    "fm": {"inst": "synlead", "gain": 0.14},     # the FM synth
    "pluck": {"inst": "pluck", "gain": 0.64},    # a plucked string
}
HOOK_VOICES = {
    "fm": {"inst": "synlead", "gain": 0.28},     # the FM synth, the fourth round's
    "lead": {"inst": "lead", "gain": 0.25},      # the synth lead
}
SYNTH_PARTS = tuple("arp:" + v for v in ARP_VOICES) + tuple("hook:" + v for v in HOOK_VOICES)

SCALE = (0, 2, 3, 5, 7, 8, 10)   # E natural minor, the track's key
GHOST = 0.7   # a group's sixteenths after its first, 3 dB under it


def along(home, d):
    """The note `d` steps along E minor from a chord's root."""
    o, pc = divmod(home, 12)
    k = SCALE.index(pc) + d
    return 12 * o + SCALE[k % 7] + 12 * (k // 7)


def moved(pat, by):
    """A riff pattern's notes moved `by` semitones, or along E minor by ("steps", k), a note off the
    scale (an approach note, the blues note) a minor third."""
    out = []
    for c in pat:
        if c in ".-":
            out.append(c)
            continue
        n = int(c) if c.isdigit() else F.NOTE[c]
        if isinstance(by, int):
            out.append(P.spell(n + by))
        else:
            out.append(P.spell(along(n, by[1]) if n % 12 in SCALE else n + 3))
    return "".join(out)


def jam_bar(choice, home, next_home):
    """One bar of the walk on a chord's root (in the line's first octave, E to D#) before the next
    bar's: (step, note, steps to the next hit, accented) for each hit. A hit is accented when it
    opens a group of sixteenths or falls on a beat."""
    rhythm, _, fig = choice.partition(".")
    hits = [i for i, c in enumerate(RHYTHMS[rhythm]) if c == "x"]
    notes = FIGURES[rhythm][fig]
    if len(notes) != len(hits):
        raise ValueError("%s has %d notes for %d hits" % (choice, len(notes), len(hits)))
    if "b" in notes and home != 0:
        raise ValueError("%s: the blues note is E minor's" % choice)
    out = []
    for j, (h, t) in enumerate(zip(hits, notes)):
        n = next_home - 1 if t == "A" else next_home + 1 if t == "V" else home + 6 if t == "b" else along(home, t)
        room = (hits[j + 1] if j + 1 < len(hits) else 16) - h
        out.append((h, n, room, j == 0 or hits[j - 1] != h - 1 or h % 4 == 0))
    return out


def form_roots(call):
    """The call's form and each bar's chord root, a section's chords read from its run's start."""
    form = call["form"].replace(" ", "")
    roots, run_start = [], 0
    for k, sec in enumerate(form):
        if k > 0 and form[k - 1] != sec:
            run_start = k
        chords = call["chords"][sec]
        roots.append(chords[(k - run_start) % len(chords)][0])
    return form, roots


def turn_parts(call, turns, hold="332"):
    """The turns' patterns by section, {part: {section: pattern}}: the walk split into its accented
    hits ("walk") and the rest ("ghost"), the hold's guitar and bass, and the bars the arpeggio and
    the hook play. A walking note holds two steps where it has room."""
    form, roots = form_roots(call)
    out = {key: {} for key in ("walk", "ghost", "hold_guitar", "hold_bass") + SYNTH_PARTS}
    rest = "." * 16
    for k, sec in enumerate(form):
        if sec not in turns or (k > 0 and form[k - 1] == sec) or sec in out["walk"]:
            continue
        n = 1
        while k + n < len(form) and form[k + n] == sec:
            n += 1
        if n > 2 * len(turns[sec]):
            raise ValueError("%s runs %d bars on %d turns" % (sec, n, len(turns[sec])))
        hook = P.part(call, "chime_metal", sec, mode="chord") if any(t.split(":")[0] in ("hook", "both") for _c, t in turns[sec]) else rest
        bars_ = {key: [] for key in out}
        for i in range(n):
            choice, synth = turns[sec][i // 2]
            synth, _, voicing = synth.partition(":")
            arp_voice, hook_voice = VOICINGS[voicing or "back"]
            root, next_root = roots[k + i], roots[(k + i + 1) % len(form)]
            played = {}
            if choice == "rest":
                pass
            elif choice == "hold":
                guitar, bass = HOLDS[hold]
                played = {"hold_guitar": guitar(root, next_root), "hold_bass": bass(root, next_root)}
            elif synth == "both":
                raise ValueError("%s %s: the walk takes the arpeggio or the hook, never both" % (sec, choice))
            else:
                for key, acc in (("walk", True), ("ghost", False)):
                    bar = ["."] * 16
                    for h, note, room, accented in jam_bar(choice, root % 12, next_root % 12):
                        if accented == acc:
                            bar[h] = P.spell(note)
                            for q in range(1, min(room, 2)):
                                bar[h + q] = "-"
                    played[key] = "".join(bar)
            for key in ("walk", "ghost", "hold_guitar", "hold_bass"):
                bars_[key].append(played.get(key, rest))
            for v in ARP_VOICES:
                bars_["arp:" + v].append(ARP if synth in ("arp", "both") and v == arp_voice else rest)
            for v in HOOK_VOICES:
                bars_["hook:" + v].append(hook[16 * i % len(hook):][:16] if synth in ("hook", "both") and v == hook_voice else rest)
        for key in out:
            out[key][sec] = "".join(bars_[key])
    return out


def battle_half(call, turns=None, hold="332", split=UP_SPLIT, d=D_PLAN, bass_db=BASS_DB):
    """Night Shift's battle half: see the module's notes. `hold` is what the guitar and the bass play
    under the hook and the arpeggio together; `split` the guitar's interval over the bass in the
    later spot (SPLITS); `d` D's turn; `bass_db` the driven bass's level, wherever it plays."""
    up_octave, by = SPLITS[split]
    p = lambda *a, **k: P.part(call, *a, **k)   # noqa: E731
    riff = p("bass", "D", gain=0.34)
    voices = []
    for v in call["voices"]:
        inst, v = v["inst"], dict(v)
        if inst in ("guitar_real", "bass"):
            continue   # the mechanical guitar and the crunch synth's dark roots and riff: the walk, the hold and the riff below
        if inst == "brass":
            v["gain"] = 0.24
        elif inst == "chime_metal":
            v["gain"] = 0.2
        elif inst == "sub_bass" and "A" in v["pat"]:
            v["gain"] = 0.24   # the pulse under the line
        elif inst == "lead":
            v.update(inst="lead_real", gain=0.3)
        voices.append(v)
    parts = turn_parts(call, dict(turns or TURNS, D=D_TURNS[d]), hold)
    for key, g in (("walk", 1.0), ("ghost", GHOST)):
        # The guitar palm-muted and the driven bass in unison through the walk, a group's first
        # sixteenth on top: the guitar on its interval over the bass in the later spot, the bass on
        # the riff in D.
        voices += [
            {"inst": "guitar_real", "mode": "riff", "gain": 0.45 * g, "octave": -1, "pat": {s: x for s, x in parts[key].items() if s != UP}},
            {"inst": "bass_real", "mode": "riff", "gain": 0.27 * g, "hold": 0.9, "octave": -1, "params": {"drive": 3.5},
             "pat": {s: x for s, x in parts[key].items() if s != "D" or d != "copy"}},
            {"inst": "guitar_real", "mode": "riff", "gain": UP_GAIN * g, "octave": up_octave, "pat": {s: moved(x, by) for s, x in parts[key].items() if s == UP}},
        ]
    voices += [
        # The hold under the hook and the arpeggio together.
        {"inst": "guitar_real", "mode": "riff", "gain": 0.45 * HOLD, "octave": -1, "pat": parts["hold_guitar"]},
        {"inst": "bass_real", "mode": "riff", "gain": 0.27 * HOLD, "hold": 0.9, "octave": -1, "params": {"drive": 3.5}, "pat": parts["hold_bass"]},
        # The riff in D (on the driven bass and the crunch synth as the fourth round had it, the
        # map's dark synth alone, or the crunch synth alone two bars in four), held roots through
        # the breakdown.
        {"inst": "bass_real", "mode": "riff", "gain": 0.38, "hold": 1.1, "params": {"drive": 3.5}, "pat": {"D": riff} if d == "copy" else {}},
        {"inst": "bass", "mode": "riff", "gain": 0.3, "hold": 1.0, "params": {"drive": 3.5, "cutoff": 900.0}, "pat": {"D": riff}} if d == "copy" else
        dict(NOD, inst="bass", mode="riff", pat={"D": riff}) if d in ("piano", "factory", "blend") else
        {"inst": "bass", "mode": "riff", "gain": CALL, "octave": 1, "hold": 1.0, "params": {"drive": 3.5, "cutoff": 1200.0}, "pat": {"D": riff + "." * 32}},
        {"inst": "bass_real", "mode": "riff", "gain": 0.32, "legato": True, "params": {"drive": 3.5}, "pat": {"B": p("sub_bass", "B")}},
        # Ringing chords through the breakdown.
        {"inst": "guitar_hold", "mode": "stab", "gain": 0.55, "dur": 16, "pat": {"B": "x..............."}},
        # The synth lines by turns, each voice in the bars its voicing gives it: the arpeggio, up
        # and down two octaves of each chord in sixteenths, and the chime's hook an octave under it.
    ] + [dict(ARP_VOICES[v], mode="chord", octave=2, dur=1.4, pat=parts["arp:" + v]) for v in ARP_VOICES] + [
        dict(HOOK_VOICES[v], mode="chord", octave=1, dur=3.0, pat=parts["hook:" + v]) for v in HOOK_VOICES]
    # D's piano: the house piano's chord, each tone a voice an octave up, stabbing three-three-two.
    voices += [{"inst": "epiano", "mode": "chord", "octave": 1, "gain": PIANO_BLEND if d == "blend" else PIANO_D, "dur": 1.5,
                "pat": {"D": THREE_THREE_TWO.replace("r", str(k))} if d in ("piano", "blend") else {}} for k in range(3)]
    voices = [dict(v, gain=v["gain"] * 10.0 ** (bass_db / 20.0)) if v["inst"] == "bass_real" else v for v in voices]
    drums = {
        "kick": {"I": "x...x...x...x..." * 7 + "x...x...x.......", "A": GROOVE_KICK, "C": LEAD_KICK, "R": GROOVE_KICK,
                 "B": "x.....x...x....." * 6 + "x...x...x...x..." + "x.x.x.x.x.x.x.x.",
                 "D": "x.xx..x.x.xx..x." * 3 + "x.xx..x.x.xx.xx." + "x.xx..x.x.xx..x." * 2 + "x.xx.xx.x.xx.xx." + "x...x...x.......",
                 "O": bars("x...x...x...x..x", "x...x..xx...x...") * 4},
        "kick_hard": {"D": "." * 120 + "xxxxxxxx"},   # a double-kick run out of the riff
        "snare": {"I": "....x.......x..." * 8, "A": GROOVE_SNARE, "C": GROOVE_SNARE, "R": GROOVE_SNARE,
                  "B": "........x......." * 6 + "4.4.5.5.6.6.7.7." + "5566778899xxxxxx",   # half time, then a build
                  "D": "....x..o.o..x..o" * 7 + "....x.......x.x.",
                  "O": bars("....x..o....x..o", "....x..o.o..x...") * 4},
        "hat": {"I": HATS, "A": HATS, "R": "x" * 112 + "xxxxxxxx........", "O": "xx.xxx.xxx.xxx.x",
                "B": "x.x.x.x.x.x.x.x." * 6 + "." * 32, "D": "x" * 120 + "........"},
        "open": {"I": OPENS, "A": OPENS, "O": "..x...x...x...x.", "C": "..............x." * 7 + "." * 16},
        "ride": {"C": "x.x.x.x.x.x.x.x." * 7 + "x.x.x.x........."},
        # A crash at every door but the top's (Ryan: it broke the loop), and each phrase.
        "crash": {"*": P.door_pattern(call, "ABCDRO"), "A": "x" + "." * 127, "C": "x" + "." * 127,
                  "D": "x" + "." * 31, "R": "x" + "." * 31},
        "china": {"A": "." * 62 + "x." + "." * 64, "C": "." * 62 + "x." + "." * 64, "O": "." * 62 + "x." + "." * 64,
                  "D": "........x......." + "." * 16, "R": "........x......." + "." * 16},
        "stack": {"D": "..x...x...x...x.", "R": "..x...x...x...x."},
        "tom": {s: FILLS["tom"] for s in "IACR"},
        "tom2": {s: FILLS["tom2"] for s in "IACR"},
        # The map's industry over the kit.
        "knock": {s: "......x.......x." for s in "ACRO"} | {"D": "..x...x...x...x."},
        "tick": {s: "x" * 16 for s in "ACRO"},
        "clank": {"A": "..............x" + "." * 49, "R": "..............x" + "." * 17, "D": "..............x" + "." * 17},
        "glitch": {"I": "........x.......", "A": "...x.......x....x.........x.....", "D": "...x.......x....", "O": "........x......."},
    }
    if d != "copy":
        # Night Shift's four on the floor under the map's sixteenths and its stack, the backbeat
        # over it, a crash every phrase; no gallop, china or double kick.
        drums["kick"]["D"] = "x...x...x...x..." * 7 + "x...x...x...x.x."
        drums["snare"]["D"] = "....x.......x..." * 7 + "....x.......x.x."
        drums["hat"]["D"] = "x" * 128
        drums["kick_hard"].pop("D")
        drums["china"].pop("D")
        drums["crash"]["D"] = "x" + "." * 31 if d == "trade" else "x" + "." * 63   # on each call and answer, or each phrase
        if d == "blend":
            drums["knock"]["D"] = BLEND_KNOCK
            drums["clank"]["D"] = BLEND_CLANK
            drums["tick"]["D"] = BLEND_TICK
        if d == "factory":
            # The industry on three-three-two: the knocks on it, a clank on three, the ticks in sixteenths.
            drums["knock"]["D"] = "x..x..x.x..x..x.".replace("x", FACTORY)
            drums["clank"]["D"] = "........x.......".replace("x", FACTORY)
            drums["tick"]["D"] = "x" * 16
    kit = P.fight_kit()
    kit.update({"knock": (F.knock_perc(), 0.5), "tick": (F.tick(), 0.22), "clank": (F.clank(), 0.25),
                "glitch": (F.glitch_perc(), 0.3), "kick_hard": (F.variants(F.kick_real), 1.9)})
    return {"kit": kit, "drums": drums, "voices": voices, "pad": [{"inst": "choir_real", "gain": 0.22, "vowel": "oh", "sections": "B"}],
            "drum_gain": {"I": 1.0, "A": 1.1, "B": 1.0, "C": 1.1, "D": 1.25 if d == "copy" else D_DRUMS, "R": 1.2, "O": 1.1},
            "air": (0.12, 0.06), "master": 1.1, "headroom": 0.6, "tilt": 1.5, "presence": 0.25, "low": (150.0, -6.0)}




# ---------------------------------------------------------------- the renders

def on_form(form):
    """The recipe's call on another form (an excerpt)."""
    saved = F.MUSIC[NAME]["form"]
    F.MUSIC[NAME]["form"] = form
    try:
        return P.recipe_call(F.music_night_shift)
    finally:
        F.MUSIC[NAME]["form"] = saved


def battle(form=None, mastered=True, **opts):
    """The battle half on the recipe's form or an excerpt's, every pattern read from its section's
    start as the track reads it. Unmastered, the mix stops before its master and comes back with
    the master's settings, so a set's rows go through one master together (`master_together`): a
    master that brought each row under its knee by its own peak would take back what a louder part
    adds."""
    call = on_form(form) if form else P.recipe_call(F.music_night_shift)
    kw = dict(call)
    kw.update(battle_half(call, **opts))
    settings = (kw.get("headroom"), kw.get("master", 1.25))
    if not mastered:
        kw.update(headroom=None, master=1e-3)   # tanh at a thousandth of its drive: linear to a part in a million
    with P.Patched(_steps=run_steps):
        x = F.groove(**kw)
    return x if mastered else (x, settings)


def map_half():
    return F.groove(**map_intro(P.recipe_call(F.music_night_shift)))


SETS = [
    {"id": "b", "half": "battle", "title": "The battle's walk with the driven bass", "form": "R" * 8,
     "note": "The groove again, the walk with the hook pushed on the synth lead, the guitar a tenth over the driven bass.",
     "rows": [("b0", "The driven bass as it was", "As the eighth round had it.", {"bass_db": 0.0}),
              ("b1", "The driven bass 3 dB down", "As it is everywhere in the full pair.", {})]},
]
PAIR = {"id": "night_shift_r9", "title": "Night Shift, round nine"}
INTRO = "intro: the kick on every beat and the hats, the pad fading in through the fourth bar and swelling from 0:10, the sub from the fifth"
TURNS_SAID = {   # each section's turns in the battle half, on the page beside the map half's
    "I": "three-three-two on the root all through, the arpeggio on the plucked string from the fifth bar",
    "A": "the hook pushed on the synth lead over the arpeggio on the FM synth and the hold, then the walk with the hook on the FM synth from the ninth bar",
    "B": "the breakdown: held roots and ringing chords under the choir",
    "C": "the lead guitar's long notes over the walk, the arpeggio joining behind them on the synth lead at the ninth bar",
    "D": "the piano and the factory blended: the house piano stabbing the chords in three-three-two over the hold, the knocks in its gaps, the riff dark and low as the map's nod",
    "R": "the walk with the guitar a tenth over the bass, the hook pushed on the synth lead",
    "O": "the arpeggio on the plucked string and the hook on the FM synth over the hold, into the top",
}


def render_row(job):
    si, ri = job
    F.seed("night9_" + SETS[si]["id"])
    return si, ri, battle(SETS[si]["form"], mastered=False, **SETS[si]["rows"][ri][3])


def render_full(which):
    if which == "battle":
        F.seed(NAME + "_battle")
        x, db = battle(), BATTLE_LEVEL
    else:
        F.seed(NAME)
        x, db = map_half(), MAP_LEVEL
    P.write("%s_%s" % (PAIR["id"], which), F.limit(F.write_level(x, NAME, db)), aac=False)
    return which


def main(argv):
    wanted = argv or [s["id"] for s in SETS] + ["full"]
    os.makedirs(P.OUT, exist_ok=True)
    jobs = [(si, ri) for si, s in enumerate(SETS) if s["id"] in wanted for ri in range(len(s["rows"]))]
    with ProcessPoolExecutor(max_workers=4) as pool:
        fulls = [pool.submit(render_full, w) for w in (("battle", "map") if "full" in wanted else ())]
        raw = {(si, ri): x for si, ri, x in pool.map(render_row, jobs)}
        for f in fulls:
            f.result()
    path = os.path.join(P.OUT, "night9.json")
    manifest = json.load(open(path)) if os.path.exists(path) else {"sets": [], "tracks": [], "seams": []}
    for si, s in enumerate(SETS):
        if s["id"] not in wanted:
            continue
        # One master and one gain for the set, the gain the one that brings its first row to the
        # battle's level, so the rows differ only by what changed.
        mastered = master_together([raw[si, ri] for ri in range(len(s["rows"]))])
        gain = 10.0 ** ((BATTLE_LEVEL - F.mean_level(mastered[0])) / 20.0)
        rows = []
        for ri, (rid, title, note, _opts) in enumerate(s["rows"]):
            x = F.limit(mastered[ri] * gain)
            rows.append({"id": rid, "title": title, "note": note, "file": os.path.basename(P.write("night9_" + rid, x)),
                         "seconds": round(len(x) / F.SR, 2), "phone_db": P.measure(rid, x)["phone_db"]})
        manifest["sets"] = [e for e in manifest["sets"] if e["id"] != s["id"]] + [{"id": s["id"], "half": s["half"], "title": s["title"], "note": s["note"], "rows": rows}]
        print("%-2s %s" % (s["id"], "  ".join("%s %.1f" % (r["id"], r["phone_db"]) for r in rows)))
    manifest["sets"].sort(key=lambda e: [s["id"] for s in SETS].index(e["id"]))
    manifest["seams"] = []
    if "full" in wanted:
        m, b = (P.read_wav(os.path.join(P.OUT, "%s_%s.wav" % (PAIR["id"], w))) for w in ("map", "battle"))
        if len(m) != len(b):
            raise ValueError("the halves are %d and %d samples" % (len(m), len(b)))
        P.write(PAIR["id"] + "_pair", [m, b], kbps=384)
        runs, total = F.sections(NAME)
        levels = [P.measure("map", m), P.measure("battle", b)]
        manifest["tracks"] = [{"id": PAIR["id"], "title": PAIR["title"], "new": "both", "bpm": F.MUSIC[NAME]["bpm"], "length": round(total, 3),
                               "loop_from_bar": 1, "bar_at": [round(float(t), 4) for t in P.bar_times(NAME)],
                               "sections": [{"section": s, "bars": [b0, b1], "at": round(at, 2),
                                             "what": "%s; the battle: %s" % (INTRO if s == "I" else what, TURNS_SAID[s])} for s, b0, b1, at, what in runs],
                               "levels": levels}]
        print("%s  map %.1f (phone %.1f)  battle %.1f (phone %.1f)" % (PAIR["id"], levels[0]["mean_db"], levels[0]["phone_db"], levels[1]["mean_db"], levels[1]["phone_db"]))
    with open(path, "w") as f:
        json.dump(manifest, f, indent=1)
    print(os.path.relpath(path))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

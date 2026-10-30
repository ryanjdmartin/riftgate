"""Night Shift's fourth round as a pair (Ryan, 30 October, on the third): the battle half as a whole jam.

  "The jam with every 2 bars is good. The only one out of place is the long held pull-back in spot
  3 (and again later), that one is too jarringly slow. Less busy bars are ok, but not that one."
  "I would save the octave-up for a later spot in the track, and I would bump up the upper volume
  so it sounds like a true unison." "When the hook and the arpeggio are running together, the walk
  needs to calm down back to holding the rhythm and chords like your first take, and go down in
  volume. When we're walking, the arpeggios or the hook are great, but not both. We need to mix
  and match as we go along, this is now turning into our grooviest track. Jam session, everybody
  gets a turn, we keep it moving, we try different additions at different points."

So the battle half runs in turns of two bars. In a walking turn the guitar and the driven bass play
one line in unison on one of six rhythms (his four, three-three-two and the gallop), a figure
walking each bar's chord along E minor, with the arpeggio or the FM hook over it, never both; the
held pull-back is gone. Where both run, the guitar and the bass hold the groove 6 dB down: the
guitar on three-three-two on each chord's root and the bass on its line in that rhythm (the second
round's groove, the third round's first row), or round one's eighths on the roots, a set beside it.
The turns: the intro on the root, then the walk with the arpeggio; the groove's head on the hook
and the arpeggio over the hold, then the walk with the hook; the breakdown; the lead guitar's long
notes over the walk alone, then the arpeggio joining; the riff in D; the groove again with the
guitar an octave over the bass, raised to meet it, and the hook; the outro's head over the hold,
which runs into the intro's groove at the top.

Kept from the third round: the map half (the intro without its front), no crash at the top and no
drone, the drums (Night Shift's four on the floor under Hold The Line's density, the map's industry
over the kit), the breakdown's held roots and ringing chords, the riff in D on the driven bass and
the crunch synth (the guitar on three-three-two under it), the piano off the beat, the chime's
hook, the lead's long notes on the lead guitar, the choir.

    tools/spriter/.venv/bin/python tools/soundforge/night_sketches.py          # the sets and the full pair, then night4.json beside the pairs
    tools/spriter/.venv/bin/python tools/soundforge/night_sketches.py h        # the named sets only (h u, and full for the pair and the seam)
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
# the arpeggio or the hook, never both. The chords run Em C D Bm Em A G D through A, C and R, E
# minor through the intro, Em Em D G through D and Em C Bm Em through the outro; the breakdown (B)
# keeps its own voices, and the bass plays the riff in D over the guitar's groove.
TURNS = {
    "I": [("332.home", ""), ("332.home", ""), ("offbeats.blues", "arp"), ("threes.climb", "arp")],
    "A": [("hold", "both")] * 4 + [("offbeats.run", "hook"), ("gallop.drive", "hook"), ("bursts.rise", "hook"), ("threes.octs", "hook")],
    "C": [("332.lift", ""), ("pairs.pops", ""), ("gallop.walk", ""), ("threes.climb", ""),   # under the lead guitar's long notes
          ("offbeats.zigzag", "arp"), ("bursts.chug", "arp"), ("pairs.stairs", "arp"), ("threes.steps", "arp")],
    "D": [("332.home", "")] * 4,
    "R": [("pairs.pops", "hook"), ("gallop.octs", "hook"), ("bursts.turn", "hook"), ("threes.climb", "hook")],
    "O": [("hold", "both")] * 4,
}
UP = "R"   # the later spot where the guitar plays an octave over the bass ("save the octave-up for a later spot")
# The guitar an octave up 6 dB over the third round's ("bump up the upper volume so it sounds like a
# true unison"): there it measured within a dB of the bass on a phone's speaker, the bass's overtones
# sitting on its octave.
UP_GAIN = 0.9
ARP = "0123432101234321"   # up and down two octaves of the chord in sixteenths

SCALE = (0, 2, 3, 5, 7, 8, 10)   # E natural minor, the track's key
GHOST = 0.7   # a group's sixteenths after its first, 3 dB under it


def along(home, d):
    """The note `d` steps along E minor from a chord's root."""
    o, pc = divmod(home, 12)
    k = SCALE.index(pc) + d
    return 12 * o + SCALE[k % 7] + 12 * (k // 7)


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
    out = {key: {} for key in ("walk", "ghost", "hold_guitar", "hold_bass", "arp", "hook")}
    rest = "." * 16
    for k, sec in enumerate(form):
        if sec not in turns or (k > 0 and form[k - 1] == sec) or sec in out["walk"]:
            continue
        n = 1
        while k + n < len(form) and form[k + n] == sec:
            n += 1
        if n > 2 * len(turns[sec]):
            raise ValueError("%s runs %d bars on %d turns" % (sec, n, len(turns[sec])))
        hook = P.part(call, "chime_metal", sec, mode="chord") if any(t in ("hook", "both") for _c, t in turns[sec]) else rest
        bars_ = {key: [] for key in out}
        for i in range(n):
            choice, synth = turns[sec][i // 2]
            root, next_root = roots[k + i], roots[(k + i + 1) % len(form)]
            played = {}
            if choice == "hold":
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
            bars_["arp"].append(ARP if synth in ("arp", "both") else rest)
            bars_["hook"].append(hook[16 * i % len(hook):][:16] if synth in ("hook", "both") else rest)
        for key in out:
            out[key][sec] = "".join(bars_[key])
    return out


def battle_half(call, turns=None, hold="332", up_gain=UP_GAIN):
    """Night Shift's battle half: see the module's notes. `hold` is what the guitar and the bass play
    under the hook and the arpeggio together; `up_gain` the guitar's level an octave over the bass."""
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
    parts = turn_parts(call, turns or TURNS, hold)
    for key, g in (("walk", 1.0), ("ghost", GHOST)):
        # The guitar palm-muted and the driven bass in unison through the walk, a group's first
        # sixteenth on top: the guitar an octave over the bass in the later spot, the bass on the
        # riff in D.
        voices += [
            {"inst": "guitar_real", "mode": "riff", "gain": 0.45 * g, "octave": -1, "pat": {s: x for s, x in parts[key].items() if s != UP}},
            {"inst": "bass_real", "mode": "riff", "gain": 0.27 * g, "hold": 0.9, "octave": -1, "params": {"drive": 3.5},
             "pat": {s: x for s, x in parts[key].items() if s != "D"}},
            {"inst": "guitar_real", "mode": "riff", "gain": up_gain * g, "octave": 0, "pat": {s: x for s, x in parts[key].items() if s == UP}},
        ]
    voices += [
        # The hold under the hook and the arpeggio together.
        {"inst": "guitar_real", "mode": "riff", "gain": 0.45 * HOLD, "octave": -1, "pat": parts["hold_guitar"]},
        {"inst": "bass_real", "mode": "riff", "gain": 0.27 * HOLD, "hold": 0.9, "octave": -1, "params": {"drive": 3.5}, "pat": parts["hold_bass"]},
        # The riff in D, held roots through the breakdown.
        {"inst": "bass_real", "mode": "riff", "gain": 0.38, "hold": 1.1, "params": {"drive": 3.5}, "pat": {"D": riff}},
        {"inst": "bass", "mode": "riff", "gain": 0.3, "hold": 1.0, "params": {"drive": 3.5, "cutoff": 900.0}, "pat": {"D": riff}},
        {"inst": "bass_real", "mode": "riff", "gain": 0.32, "legato": True, "params": {"drive": 3.5}, "pat": {"B": p("sub_bass", "B")}},
        # Ringing chords through the breakdown.
        {"inst": "guitar_hold", "mode": "stab", "gain": 0.55, "dur": 16, "pat": {"B": "x..............."}},
        # The synth lines by turns: the arpeggio, up and down two octaves of each chord in
        # sixteenths on the lead's voice, and the chime's hook an octave under it on the FM synth.
        {"inst": "lead", "mode": "chord", "octave": 2, "gain": 0.16, "dur": 1.4, "pat": parts["arp"]},
        {"inst": "synlead", "mode": "chord", "octave": 1, "gain": 0.28, "dur": 3.0, "pat": parts["hook"]},
    ]
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
    kit = P.fight_kit()
    kit.update({"knock": (F.knock_perc(), 0.5), "tick": (F.tick(), 0.22), "clank": (F.clank(), 0.25),
                "glitch": (F.glitch_perc(), 0.3), "kick_hard": (F.variants(F.kick_real), 1.9)})
    return {"kit": kit, "drums": drums, "voices": voices, "pad": [{"inst": "choir_real", "gain": 0.22, "vowel": "oh", "sections": "B"}],
            "drum_gain": {"I": 1.0, "A": 1.1, "B": 1.0, "C": 1.1, "D": 1.25, "R": 1.2, "O": 1.1},
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
    {"id": "h", "half": "battle", "title": "The battle's hold under the hook and the arpeggio", "form": "A" * 8,
     "note": "The groove's head, its eight chords with the hook, the arpeggio and the drums; the guitar and the bass hold the groove 6 dB under the walk.",
     "rows": [("h0", "Three-three-two on the roots", "The guitar on each chord's root and the bass on its line in that rhythm: the second round's groove, the third round's first row (the full pair's).", {}),
              ("h1", "Eighths on the roots", "Round one's: the guitar and the bass in straight eighths on each chord's root.", {"hold": "eighths"})]},
    {"id": "u", "half": "battle", "title": "The battle's walk with the guitar an octave up", "form": "R" * 8,
     "note": "The groove again, the walk with the hook, the guitar an octave over the driven bass. In the third round the two already measured within a dB of each other on a phone's speaker (the bass's overtones sit on the guitar's octave), so the guitar goes up in steps for the ear.",
     "rows": [("u0", "At the third round's level", "The guitar an octave up as you heard it in the third round.", {"up_gain": 0.45}),
              ("u1", "3 dB up", "The guitar an octave up 3 dB over the third round's.", {"up_gain": 0.45 * 2.0 ** 0.5}),
              ("u2", "6 dB up", "The guitar an octave up 6 dB over the third round's (the full pair's).", {})]},
]
PAIR = {"id": "night_shift_r4", "title": "Night Shift, round four"}
INTRO = "intro: the kick on every beat and the hats, the pad fading in through the fourth bar and swelling from 0:10, the sub from the fifth"
TURNS_SAID = {   # each section's turns in the battle half, on the page beside the map half's
    "I": "three-three-two on the root, then the walk with the arpeggio from the fifth bar",
    "A": "the hook and the arpeggio over the hold, then the walk with the hook from the ninth bar",
    "B": "the breakdown: held roots and ringing chords under the choir",
    "C": "the lead guitar's long notes over the walk, the arpeggio joining at the ninth bar",
    "D": "the riff in D on the driven bass and the crunch synth over three-three-two",
    "R": "the walk with the guitar an octave over the bass, and the hook",
    "O": "the hook and the arpeggio over the hold, into the top",
}


def render_row(job):
    si, ri = job
    F.seed("night4_" + SETS[si]["id"])
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


def seam(x):
    """The loop's seam as the game plays it: the outro's last four bars, then the top on into the groove's fifth bar."""
    at = P.bar_times(NAME)
    return np.concatenate([x[int(round(at[68] * F.SR)):], x[:int(round(at[12] * F.SR))]])


def main(argv):
    wanted = argv or [s["id"] for s in SETS] + ["full"]
    os.makedirs(P.OUT, exist_ok=True)
    jobs = [(si, ri) for si, s in enumerate(SETS) if s["id"] in wanted for ri in range(len(s["rows"]))]
    with ProcessPoolExecutor(max_workers=4) as pool:
        fulls = [pool.submit(render_full, w) for w in (("battle", "map") if "full" in wanted else ())]
        raw = {(si, ri): x for si, ri, x in pool.map(render_row, jobs)}
        for f in fulls:
            f.result()
    path = os.path.join(P.OUT, "night4.json")
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
            rows.append({"id": rid, "title": title, "note": note, "file": os.path.basename(P.write("night4_" + rid, x)),
                         "seconds": round(len(x) / F.SR, 2), "phone_db": P.measure(rid, x)["phone_db"]})
        manifest["sets"] = [e for e in manifest["sets"] if e["id"] != s["id"]] + [{"id": s["id"], "half": s["half"], "title": s["title"], "note": s["note"], "rows": rows}]
        print("%-2s %s" % (s["id"], "  ".join("%s %.1f" % (r["id"], r["phone_db"]) for r in rows)))
    manifest["sets"].sort(key=lambda e: [s["id"] for s in SETS].index(e["id"]))
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
        # The battle half's seam beside the third round's; the map half is the second round's own.
        was = P.read_wav(os.path.join(P.OUT, "night_shift_r3_battle.wav"))
        rows = []
        for rid, title, note, src in (("r3", "Round three", "The outro pulling back into the intro's three-three-two on the root.", was),
                                      ("r4", "Round four", "The outro's hook and arpeggio over the hold, into the intro's three-three-two on the root.", b)):
            cut = seam(src)
            rows.append({"id": "battle_" + rid, "title": title, "note": note, "seconds": round(len(cut) / F.SR, 2),
                         "file": os.path.basename(P.write("night4_seam_battle_" + rid, cut))})
        manifest["seams"] = [{"id": "nb", "half": "battle", "title": "The battle half's loop: the outro into the top",
                              "note": "The outro's last four bars, then the top into the groove's fifth bar, as the game loops it.", "rows": rows}]
        print("%s  map %.1f (phone %.1f)  battle %.1f (phone %.1f)" % (PAIR["id"], levels[0]["mean_db"], levels[0]["phone_db"], levels[1]["mean_db"], levels[1]["phone_db"]))
    with open(path, "w") as f:
        json.dump(manifest, f, indent=1)
    print(os.path.relpath(path))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

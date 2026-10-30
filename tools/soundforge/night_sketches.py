"""Night Shift's third round as a pair (Ryan, 30 October, on the second): the battle half as a jam.

  "As far as grooves go, no to the 'hook rhythm,' the 3-3-2 is good, so is the gallop since its
  pretty much the same." Four more of his from the Melody Desk, rhythm only. "These groove lines
  can walk all over the place, I think. And change between all these great rhythm options, even
  bar to bar. I think the sound of the battle version of this track is just like, a jam session
  groove, just riffing with sound and rhythm. Sometimes pull it back to let the other sounds like
  the arpeggio and hook come through, but Jam Session is really the vibe." And: "I kind of want
  to hear night shift with both the apreggio and the FM hook."

So the guitar and the driven bass play one line in unison, each bar on one of six rhythms (his
four, the three-three-two and the gallop) with a figure that walks the bar's chord along E minor:
octave pops, a run up the scale, a pedal under a falling top line, the blues scale on E, a turn
on B minor's flat second, a chromatic step into the next chord on the bar's last hit. A group's
first sixteenth is accented and the rest sit a little under it. Some bars pull back (the root held
with a pickup, or the breakdown's half time) so the arpeggio and the hook come through: two in
each pass of the groove's eight chords, more under the lead's long notes in C, one in the reprise.
The intro states three-three-two on the root and starts riffing where the arpeggio enters; the
outro pulls back into it, so the loop's seam is the plain groove. The arpeggio on the lead's
voice and the chime's hook an octave under on the FM synth play together.

Kept from the second round: the map half (the intro without its front), no crash at the top and
no drone, the drums (Night Shift's four on the floor under Hold The Line's density, the map's
industry over the kit), the breakdown's held roots and ringing chords, the riff in D on the
driven bass and the crunch synth (the guitar on three-three-two under it), the piano off the
beat, the chime's hook, the lead's long notes on the lead guitar, the choir.

    tools/spriter/.venv/bin/python tools/soundforge/night_sketches.py          # the sets and the full pair, then night3.json beside the pairs
    tools/spriter/.venv/bin/python tools/soundforge/night_sketches.py j        # the named sets only (j s, and full for the pair and the seam)
"""
import json
import os
import sys
from concurrent.futures import ProcessPoolExecutor

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import pair_sketches as P  # noqa: E402
from hold_sketches import copied, run_steps  # noqa: E402

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

# The second round's groove, one bar on each chord's root: the reference row's.
THREE_THREE_TWO = "r..r..r.r..r..r."

# The bass line's notes for each chord as (root, its octave, its fifth, the passing note into the
# next chord), on the driven bass an octave down (0 is E1).
CHORD_NOTES = {   # by the chord's root and the next chord's root
    (0, 8): ("0", "c", "7", "7"), (8, 10): ("8", "e", "c", "9"), (10, 7): ("a", "j", "f", "8"), (7, 0): ("7", "i", "d", "l"),
    (0, 5): ("0", "c", "7", "4"), (5, 3): ("5", "f", "c", "4"), (3, -2): ("3", "e", "a", "9"), (-2, 0): ("a", "j", "f", "l"),
    (0, 0): ("0", "c", "7", "l"), (8, 7): ("8", "e", "c", "8"),
}


def line(fig, roots):
    """The bass line on a groove over a run of bar roots (each with the next, the last wrapping to
    the first): a hit by the and of two takes the octave, one by the a of three the fifth, the
    bar's last hit from beat four the passing note, the rest the root; a hit with room after it
    holds two steps."""
    hits = [i for i, c in enumerate(fig) if c == "r"]
    out = []
    for b, r in enumerate(roots):
        root, octave, fifth, passing = CHORD_NOTES[r, roots[(b + 1) % len(roots)]]
        bar = ["."] * 16
        for j, h in enumerate(hits):
            last = j == len(hits) - 1
            bar[h] = passing if last and h >= 12 else octave if 6 <= h <= 7 else fifth if 11 <= h <= 13 else root
            if (16 if last else hits[j + 1]) - h >= 3:
                bar[h + 1] = "-"
        out.append("".join(bar))
    return "".join(out)


def bar_roots(call, section, n=None):
    chords = call["chords"][section]
    return [chords[b % len(chords)][0] for b in range(n or len(chords))]


# The jam's rhythms (Ryan, 30 October): the two he kept of the second round's grooves and his four
# from the Melody Desk, a bar's hits in sixteenths; then the two ways it pulls back.
RHYTHMS = {
    "332": "x..x..x.x..x..x.",       # three, three, two
    "gallop": "x.xx..x.x.xx..x.",    # pairs of sixteenths pushing into the beat
    "pairs": "xx.xx.xx.xx.x.x.",     # his first
    "offbeats": "xx.x.x.x.x.xx.x.",  # his second
    "bursts": "xxx..x.x.x..xxx.",    # his third
    "threes": "xxx..xxx..x.xxx.",    # his fourth
    "space": "x.............x.",     # pulled back: the root held, a pickup
    "half": "x.....x...x.....",      # pulled back: the breakdown's half time
}
PULLED = ("space", "half")

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
    "space": {"": [0, "A"]},
    "half": {"": [0, 4, 0]},
}

# The jam bar by bar, a rhythm and its figure or a pull-back. The chords run Em C D Bm Em A G D
# through A, C and R, E minor through the intro, Em C Bm Em through the outro; in D the guitar
# keeps three-three-two on the roots under the riff.
JAM = {
    "I": ["332.home"] * 4 + ["offbeats.blues", "332.lift", "bursts.chug", "threes.climb"],
    "A": ["332.lift", "332.lift", "pairs.pops", "bursts.turn", "space", "half", "gallop.walk", "threes.climb",
          "offbeats.run", "offbeats.zigzag", "gallop.drive", "pairs.stairs", "space", "bursts.rise", "threes.octs", "pairs.fall"],
    "C": ["space", "332.home", "332.lift", "offbeats.zigzag", "half", "space", "bursts.chug", "threes.steps",
          "332.climb", "gallop.octs", "pairs.pops", "offbeats.run", "space", "threes.octs", "gallop.walk", "pairs.stairs"],
    "D": ["332.home"] * 8,
    "R": ["pairs.pops", "offbeats.run", "bursts.turn", "threes.octs", "space", "332.lift", "gallop.walk", "threes.climb"],
    "O": ["332.lift", "offbeats.zigzag", "pairs.fall", "332.home", "space", "half", "space", "332.home"],
}


def two_bars_each(plan):
    """The jam with each bar's rhythm and figure kept for two bars."""
    return {s: [bars_[b - b % 2] for b in range(len(bars_))] for s, bars_ in plan.items()}


SCALE = (0, 2, 3, 5, 7, 8, 10)   # E natural minor, the track's key
GHOST = 0.7   # a group's sixteenths after its first, 3 dB under it


def along(home, d):
    """The note `d` steps along E minor from a chord's root."""
    o, pc = divmod(home, 12)
    k = SCALE.index(pc) + d
    return 12 * o + SCALE[k % 7] + 12 * (k // 7)


def jam_bar(choice, home, next_home):
    """One bar of the jam on a chord's root (in the line's first octave, E to D#) before the next
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


def jam_parts(call, plan):
    """The jam's patterns for the guitar and the bass by section, each split into its accented hits
    and the rest: {(part, accented): {section: pattern}}. A note holds two steps where it has room;
    the bass holds a pulled-back bar's notes on to the next."""
    form = call["form"].replace(" ", "")
    homes, starts, run_start = [], [], 0
    for k, sec in enumerate(form):
        if k > 0 and form[k - 1] != sec:
            run_start = k
        chords = call["chords"][sec]
        homes.append(chords[(k - run_start) % len(chords)][0] % 12)
        starts.append(run_start)
    out = {(part, acc): {} for part in ("guitar", "bass") for acc in (True, False)}
    for k, sec in enumerate(form):
        if sec not in plan or (k > 0 and form[k - 1] == sec) or sec in out["guitar", True]:
            continue
        n = 1
        while k + n < len(form) and form[k + n] == sec:
            n += 1
        bars_ = {key: [] for key in out}
        for i in range(n):
            choice = plan[sec][i % len(plan[sec])]
            notes = jam_bar(choice, homes[k + i], homes[(k + i + 1) % len(form)])
            pulled = choice in PULLED
            for part, acc in out:
                bar = ["."] * 16
                for h, note, room, accented in notes:
                    if accented != acc:
                        continue
                    hold = room - 2 if part == "bass" and pulled and room > 2 else min(room, 2)
                    bar[h] = P.spell(note)
                    for q in range(1, hold):
                        bar[h + q] = "-"
                bars_[part, acc].append("".join(bar))
        for key in out:
            out[key][sec] = "".join(bars_[key])
    return out


def battle_half(call, groove="jam", synth="both", plan=None, guitar_octave=-1):
    """Night Shift's battle half: see the module's notes. `groove` "jam" plays `plan` (the jam's own
    by default); "332" is the second round's three-three-two and its line, for reference."""
    p = lambda *a, **k: P.part(call, *a, **k)   # noqa: E731
    riff = p("bass", "D", gain=0.34)
    voices = []
    for v in call["voices"]:
        inst, v = v["inst"], dict(v)
        if inst in ("guitar_real", "bass"):
            continue   # the mechanical guitar and the crunch synth's dark roots and riff: the groove, the line and the riff below
        if inst == "brass":
            v["gain"] = 0.24
        elif inst == "chime_metal":
            v["gain"] = 0.2
        elif inst == "sub_bass" and "A" in v["pat"]:
            v["gain"] = 0.24   # the pulse under the line
        elif inst == "lead":
            v.update(inst="lead_real", gain=0.3)
        voices.append(v)
    if groove == "jam":
        # The guitar palm-muted and the driven bass in unison through the jam, a group's first
        # sixteenth on top; the bass alone holds a pulled-back bar, and plays the riff in D.
        parts = jam_parts(call, plan or JAM)
        for acc, g in ((True, 1.0), (False, GHOST)):
            voices += [
                {"inst": "guitar_real", "mode": "riff", "gain": 0.45 * g, "octave": guitar_octave, "pat": parts["guitar", acc]},
                {"inst": "bass_real", "mode": "riff", "gain": 0.27 * g, "hold": 0.9, "octave": -1, "params": {"drive": 3.5},
                 "pat": {s: p_ for s, p_ in parts["bass", acc].items() if s != "D"}},
            ]
    else:
        # The second round: the guitar on the roots in three-three-two, the line on its rhythm.
        fig = THREE_THREE_TWO
        voices += [
            {"inst": "guitar_real", "mode": "riff", "gain": 0.45, "octave": -1,
             "pat": {s: P.figure(fig, [P.spell(r) for r in bar_roots(call, s)]) for s in "IACDRO"}},
            {"inst": "bass_real", "mode": "riff", "gain": 0.27, "hold": 0.9, "octave": -1, "params": {"drive": 3.5},
             "pat": {s: line(fig, bar_roots(call, s)) for s in "IACRO"}},
        ]
    voices += [
        # The riff in D, held roots through the breakdown.
        {"inst": "bass_real", "mode": "riff", "gain": 0.38, "hold": 1.1, "params": {"drive": 3.5}, "pat": {"D": riff}},
        {"inst": "bass", "mode": "riff", "gain": 0.3, "hold": 1.0, "params": {"drive": 3.5, "cutoff": 900.0}, "pat": {"D": riff}},
        {"inst": "bass_real", "mode": "riff", "gain": 0.32, "legato": True, "params": {"drive": 3.5}, "pat": {"B": p("sub_bass", "B")}},
        # Ringing chords through the breakdown.
        {"inst": "guitar_hold", "mode": "stab", "gain": 0.55, "dur": 16, "pat": {"B": "x..............."}},
    ]
    if synth in ("arp", "both"):
        # Up and down two octaves of each chord in sixteenths on the lead's voice, the intro's
        # second half and every groove.
        arp = "0123432101234321"
        voices.append({"inst": "lead", "mode": "chord", "octave": 2, "gain": 0.16, "dur": 1.4,
                       "pat": {"I": "." * 64 + arp, "A": arp, "C": arp, "R": arp, "O": arp}})
    if synth in ("hook", "both"):
        # The chime's hook an octave under it on the FM synth, where the chime plays it.
        voices.append({"inst": "synlead", "mode": "chord", "octave": 1, "gain": 0.28, "dur": 3.0,
                       "pat": {s: p("chime_metal", s, mode="chord") for s in "ARO"}})
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


def battle(form=None, **opts):
    """The battle half on the recipe's form or an excerpt's, every pattern read from its section's
    start as the track reads it (a sixteen-bar jam would otherwise start A on its ninth bar)."""
    call = on_form(form) if form else P.recipe_call(F.music_night_shift)
    kw = dict(call)
    kw.update(battle_half(call, **opts))
    with P.Patched(_steps=run_steps):
        return F.groove(**kw)


def map_half():
    return F.groove(**map_intro(P.recipe_call(F.music_night_shift)))


SETS = [
    {"id": "j", "half": "battle", "title": "The battle's guitar and bass: the jam", "form": "A" * 16,
     "note": "The groove's sixteen bars, its eight chords twice, with the drums and both synth lines; the guitar and the bass change.",
     "rows": [("j0", "The second round's groove", "Three-three-two in every bar, the guitar on the roots and the bass line on its rhythm, for reference.", {"groove": "332"}),
              ("j1", "A jam, a new rhythm every bar", "Your four rhythms, three-three-two and the gallop, a new one almost every bar, the guitar and the bass in unison walking each chord; pulled back in the fifth and sixth bars of each pass (the full pair's).", {}),
              ("j2", "A jam, each rhythm for two bars", "The same jam with each bar's rhythm and figure played twice, so each one settles before the next.", {"plan": two_bars_each(JAM)}),
              ("j3", "The guitar an octave up", "The every-bar jam with the guitar an octave over the bass, where a phone hears it walk.", {"guitar_octave": 0})]},
    {"id": "s", "half": "battle", "title": "The battle's synth lines over the jam", "form": "A" * 8,
     "note": "The groove's first eight bars on the every-bar jam, which pulls back in its fifth and sixth.",
     "rows": [("s0", "The arpeggio", "Up and down two octaves of each chord in sixteenths on the lead's voice (the second round's).", {"synth": "arp"}),
              ("s1", "The hook", "The chime's hook doubled an octave under it on the FM synth.", {"synth": "hook"}),
              ("s2", "Both", "The arpeggio and the hook together (the full pair's).", {"synth": "both"})]},
]
PAIR = {"id": "night_shift_r3", "title": "Night Shift, round three"}
INTRO = "intro: the kick on every beat and the hats, the pad fading in through the fourth bar and swelling from 0:10, the sub from the fifth"


def render_row(job):
    si, ri = job
    F.seed("night3_" + SETS[si]["id"])
    return si, ri, battle(SETS[si]["form"], **SETS[si]["rows"][ri][3])


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
    path = os.path.join(P.OUT, "night3.json")
    manifest = json.load(open(path)) if os.path.exists(path) else {"sets": [], "tracks": [], "seams": []}
    for si, s in enumerate(SETS):
        if s["id"] not in wanted:
            continue
        gain = 10.0 ** ((BATTLE_LEVEL - F.mean_level(raw[si, 0])) / 20.0)   # one gain for the set, from its first row
        rows = []
        for ri, (rid, title, note, _opts) in enumerate(s["rows"]):
            x = F.limit(raw[si, ri] * gain)
            rows.append({"id": rid, "title": title, "note": note, "file": os.path.basename(P.write("night3_" + rid, x)),
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
                               "sections": [{"section": s, "bars": [b0, b1], "at": round(at, 2), "what": INTRO if s == "I" else what} for s, b0, b1, at, what in runs],
                               "levels": levels}]
        # The battle half's seam beside the second round's; the map half is the second round's own.
        was = P.read_wav(os.path.join(P.OUT, "night_shift_r2_battle.wav"))
        rows = []
        for rid, title, note, src in (("r2", "Round two", "Three-three-two through the seam.", was),
                                      ("r3", "Round three", "The outro pulling back into the intro's three-three-two on the root.", b)):
            cut = seam(src)
            rows.append({"id": "battle_" + rid, "title": title, "note": note, "seconds": round(len(cut) / F.SR, 2),
                         "file": os.path.basename(P.write("night3_seam_battle_" + rid, cut))})
        manifest["seams"] = [{"id": "nb", "half": "battle", "title": "The battle half's loop: the outro into the top",
                              "note": "The outro's last four bars, then the top into the groove's fifth bar, as the game loops it.", "rows": rows}]
        print("%s  map %.1f (phone %.1f)  battle %.1f (phone %.1f)" % (PAIR["id"], levels[0]["mean_db"], levels[0]["phone_db"], levels[1]["mean_db"], levels[1]["phone_db"]))
    with open(path, "w") as f:
        json.dump(manifest, f, indent=1)
    print(os.path.relpath(path))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
